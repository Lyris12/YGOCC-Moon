--Rana Tossica
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	c:SSProc(0,nil,nil,nil,s.sprcon,nil,nil,POS_FACEUP_DEFENSE,1)
	c:CannotBeTributed()
	c:CannotBeMaterial(TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
	c:Ignition(1,CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON+CATEGORY_REMOVE,nil,nil,nil,nil,nil,s.thtg,s.thop)
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsMainPhase(tp,1) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
end

function s.filter(c,oc,tp)
	if not (c:IsCode(84451804) and c:IsAbleToHand() and not c:IsForbidden() and c:CheckUniqueOnField(tp)) then return false end
	local e1=Effect.CreateEffect(oc)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetLabel(1)
	e1:SetCondition(s.sumcon)
	e1:SetOperation(s.sumop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local check=c:IsPoisonFrogSummonable()
	e1:Reset()
	return check
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,c,tp) and Duel.IsPlayerCanRemove(tp,c,REASON_SUMMON+REASON_MATERIAL) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,c,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local ct,ht=Duel.Search(g,tp)
		if ct>0 and ht>0 and c:IsRelateToEffect(e) and c:IsControler(tp) then
			local fid=c:GetFieldID()
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CONTROL+RESET_PHASE+PHASE_END-RESET_TURN_SET,EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE,1,fid)
			local e1=Effect.CreateEffect(c)
			e1:Desc(2)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
			e1:SetLabel(fid)
			e1:SetCondition(s.sumcon)
			e1:SetOperation(s.sumop)
			e1:SetValue(SUMMON_TYPE_ADVANCE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			if tc:IsSummonable(true,nil) then
				Duel.BreakEffect()
				Duel.Summon(tp,tc,true,nil)
			else
				e1:Reset()
				c:ResetFlagEffect(id)
			end
		end
	end
end
function s.sumcon(e,c)
	if c==nil then return true end
	local oc=e:GetOwner()
	local tp=c:GetControler()
	return oc:IsControler(tp) and Duel.IsPlayerCanRemove(tp,oc,REASON_SUMMON+REASON_MATERIAL) and (e:GetLabel()==1 or oc:GetFlagEffectLabel(id)==e:GetLabel())
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	local oc=e:GetOwner()
	if not (oc:IsControler(tp) and Duel.IsPlayerCanRemove(tp,oc,REASON_SUMMON+REASON_MATERIAL) and oc:GetFlagEffectLabel(id)==e:GetLabel()) then return end
	c:SetMaterial(Group.FromCards(oc))
	Duel.Remove(oc,POS_FACEUP,REASON_SUMMON+REASON_MATERIAL)
	e:Reset()
end

function Card.IsPoisonFrogSummonable(c)
	local tp=c:GetControler()
	if not c:IsSummonableCard() or c:IsForbidden() then return false end
	for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_SUMMON_COST)}) do
		if ce and ce.SetLabel then
			local cost=ce:GetCost()
			if cost and not cost(ce,c,tp) then
				return false
			end
		end
	end
	if c:IsHasEffect(EFFECT_CANNOT_SUMMON) then return false end
	--
	local peset={}
	local res=c:FilterPoisonFrogSummonProc(tp,peset)
	if #peset==0 and (aux.GetValueType(res)=="boolean" and not res or aux.GetValueType(res)=="number" and res==-2) then
		Debug.Message(res)
		return false
	end
	
	return true
end
function Card.FilterPoisonFrogSummonProc(c,tp,peset)
	if c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC) then
		for _,ce in ipairs({c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC)}) do
			if ce and ce.SetLabel then
				if c:CheckPoisonFrogSummonProc(ce,tp) then
					table.insert(peset,ce)
				end
			end
		end
		if #peset>0 then
			return -1
		end
		return -2
	end
end
function Card.CheckPoisonFrogSummonProc(c,ce,tp)
	if not ce:CheckCountLimit(tp) then return false end
	local toplayer=tp
	if ce:IsHasProperty(EFFECT_FLAG_SPSUM_PARAM) then
		local s,o=ce:GLGetTargetRange()
		if o and o~=0 then
			toplayer=1-tp
		end
	end
	local sumtype=ce:GetValue() and ce:GetValue() or SUMMON_TYPE_NORMAL
	for _,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_SUMMON)}) do
		if pe and pe.SetLabel then
			local tg=pe:GetTarget()
			if not tg then return false end
			if tg(pe,c,tp,sumtype,POS_FACEUP,toplayer) then return false end
		end
	end
	if not c:CheckUniqueOnField(toplayer,LOCATION_MZONE) then return false end
	
	local cond=ce:GetCondition()
	if not cond or cond(ce,c,0,0x1f) then
		return true
	end
	return false
end