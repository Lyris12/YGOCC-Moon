--Palude Carnivora
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	c:EnableCounterPermit(0x102,LOCATION_MZONE+LOCATION_FZONE)
	
	c:SummonedTrigger(false,true,false,false,0,CATEGORY_POSITION,false,nil,nil,nil,aux.PositionSelfTarget,aux.PositionSelfOperation)
	
	c:SummonedFieldTrigger(nil,true,true,true,true,1,CATEGORY_COUNTER,false,LOCATION_MZONE+LOCATION_FZONE,nil,aux.EventGroupCond(s.cf),nil,nil,aux.EventCounterSelfOperation(0x102,1,s.cf),2)
	
	c:UpdateLevelField(s.value,false,LOCATION_ONFIELD+LOCATION_HAND,true,s.lvf)
	
	c:Ignition(3,CATEGORY_COUNTER,nil,LOCATION_MZONE,{1,1},s.fdcon,nil,aux.Check(),s.fdop)
end

function s.cf(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsFaceup() and c:IsMonster() and c:IsLevelBelow(4) and (not re or c:GetReason()~=REASON_SPSUMMON or not re:GetHandler():IsCode(id))
end

function s.value(e,c)
	return e:GetHandler():GetCounter(0x102)*-2
end
function s.lvf(e,c)
	return c:IsMonster() and c:HasLevel()
end

function s.fdcon(e)
	return e:GetHandler():GetCounter(0x102)>0
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not s.fdcon(e) then return end
	local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
		Duel.BreakEffect()
	end
	local ct=c:GetCounter(0x102)
	c:Recreate(false,false,false,TYPE_SPELL+TYPE_FIELD)
	if Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true) and c:IsLocation(LOCATION_FZONE) and c:IsFaceup() then
		c:AddCounter(0x102,ct)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetCondition(s.resetcon)
		e1:SetOperation(s.resetop)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_CHANGE_POS)
		e2:SetCondition(s.resetcon2)
		Duel.RegisterEffect(e2,tp)
		e1:SetLabelObject(e2)
		e2:SetLabelObject(e1)
		--
		if c:GetCounter(0x102)>=1 then
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(id,4))
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_CHAIN_SOLVING)
			e3:SetRange(LOCATION_FZONE)
			e3:SetCondition(s.negcon)
			e3:SetOperation(s.negop)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e3)
			if c:GetCounter(0x102)>=3 then
				c:PhaseTrigger(true,PHASE_END,6,CATEGORY_REMOVE,nil,LOCATION_FZONE,1,nil,nil,aux.Check(false,aux.Info(CATEGORY_REMOVE,1,PLAYER_ALL,LOCATION_MZONE)),s.rmop,false,
				RESET_EVENT+RESETS_STANDARD)
				if c:GetCounter(0x102)>=5 then
					c:Ignition(7,CATEGORY_SPECIAL_SUMMON,nil,LOCATION_FZONE,nil,nil,aux.LabelCost,aux.CostCheck(s.costchk,s.cost,aux.Info(CATEGORY_SPECIAL_SUMMON,1,PLAYER_ALL,LOCATION_REMOVED)),s.spop,RESET_EVENT+RESETS_STANDARD)
				end
			end
		end
	end
end
function s.resetcon(e,tp,eg)
	return eg:IsContains(e:GetOwner())
end
function s.resetcon2(e,tp,eg)
	return eg:IsContains(e:GetOwner()) and e:GetOwner():IsFacedown()
end
function s.resetop(e)
	e:GetHandler():Recreate(false,false,false,TYPE_MONSTER+TYPE_EFFECT)
	e:Reset()
	local eff=e:GetLabelObject()
	if eff and aux.GetValueType(eff)=="Effect" and eff.Reset then
		eff:Reset()
	end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(0x102)
	if not re or ct<=0 then return false end
	local rc=re:GetHandler()
	return rc and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)&(LOCATION_MZONE+LOCATION_HAND)>0
		and rc:IsRatingBelow(ct,true,true,false,true) and not e:GetHandler():HasFlagEffect(id)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_CARD,0,id)
		Duel.NegateEffect(ev)
	end
end

function s.rmf(c)
	return c:IsFaceup() and c:IsMonster() and c:IsAbleToRemove()
end
function s.rating(c)
	local min=false
	local list=c:GetRating()
	for _,n in ipairs(list) do
		if not min or n and n<min then
			min=n
		end
	end
	return min
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.Group(s.rmf,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		local sg=g:GetMinGroup(s.rating):Select(tp,1,1,nil)
		if #sg>0 then
			Duel.HintSelection(sg)
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end

function s.spf(c,e,tp)
	if not (c:IsFaceup() and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	local list=c:GetRating()
	for _,n in ipairs(list) do
		if n and e:GetHandler():IsCanRemoveCounter(tp,0x102,n,REASON_COST) then
			return true
		end
	end
	return false
end
function s.spf2(c,e,tp,val)
	if not (c:IsFaceup() and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	local list=c:GetRating()
	for _,n in ipairs(list) do
		if n==val then
			return true
		end
	end
	return false
end
function s.costchk(e,tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExists(false,s.spf,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp)
end
function s.cost(e,tp)
	local g=Duel.Group(s.spf,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,e,tp)
	local lvt={}
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local list=tc:GetRating()
		for _,n in ipairs(list) do
			if n then
				lvt[n]=n
			end
		end
	end
	local pc=1
	for i=1,MAX_RATING do
		if lvt[i] then
			lvt[i]=nil
			lvt[pc]=i
			pc=pc+1
		end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	e:GetHandler():RemoveCounter(tp,0x102,lv,REASON_COST)
	Duel.SetTargetParam(lv)
end
function s.spop(e,tp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local val=Duel.GetTargetParam()
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spf2,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp,val)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end