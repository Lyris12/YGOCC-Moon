--Necroflipper
--Script by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_SEND_REPLACE)
	e0:SetTarget(cid.reptg)
	c:RegisterEffect(e0)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:GLString(0)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetTarget(cid.fliptg)
	e1:SetOperation(cid.flipop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(cid.spcon)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	--apply effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,5))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(cid.disrmcost)
	e3:SetTarget(cid.disrmtg)
	e3:SetOperation(cid.disrmop)
	c:RegisterEffect(e3)
end
cid.fu_banish_forced=true
cid.effect_memory=nil
cid.name_list={}

function cid.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetDestination()&LOCATION_REMOVED~=0 and c:GetFlagEffect(FLAG_FACEDOWN_BANISH)>0 and c:GetFlagEffect(FLAG_FAKE_FU_BANISH)<=0 end
	c:RegisterFlagEffect(FLAG_FAKE_FU_BANISH,RESET_EVENT+RESETS_STANDARD-RESET_REMOVE,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE,1)
	Duel.Remove(c,POS_FACEUP,r+REASON_FAKE_FU_BANISH)
	return true
end

function cid.checkfilter(c,e,tp,eg,ep,ev,re,r,rp)
	local check=true
	if #cid.name_list>0 then
		for i=1,#cid.name_list do
			if c:IsCode(cid.name_list[i]) then
				check=false
			end
		end
	end
	if not check then return false end
	local egroup=global_card_effect_table[c]
	if #egroup<=0 then return false end
	check=false
	local flip={}
	for i=1,#egroup do
		local ce=egroup[i]
		if ce:IsHasType(EFFECT_TYPE_FLIP) and (not ce:GetCondition() or ce:GetCondition()(e,tp,eg,ep,ev,re,r,rp))
		and (not ce:GetTarget() or ce:GetTarget()(e,tp,eg,ep,ev,re,r,rp,0)) then
			check=true
		end
	end
	if not check then return false end
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_FLIP) and c:IsAbleToDeckOrExtraAsCost() and c:IsLocation(LOCATION_REMOVED) and c:IsControler(tp)
end
function cid.fliptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)
	if #g<=0 then return end
	for tc in aux.Next(g) do
		Duel.SendtoGrave(tc,REASON_RULE)
		Duel.Remove(tc,POS_FACEUP,REASON_RULE)
	end
	if g:IsExists(cid.checkfilter,1,nil,e,tp,eg,ep,ev,re,r,rp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tc=g:FilterSelect(tp,cid.checkfilter,1,1,nil,e,tp,eg,ep,ev,re,r,rp):GetFirst()
		if tc then
			Duel.SendtoDeck(tc,nil,1,REASON_COST)
			local egroup=global_card_effect_table[tc]
			if #egroup<=0 then return end
			local flip={}
			for i=1,#egroup do
				local ce=egroup[i]
				if ce:IsHasType(EFFECT_TYPE_FLIP) and (not ce:GetCondition() or ce:GetCondition()(e,tp,eg,ep,ev,re,r,rp))
				and (not ce:GetTarget() or ce:GetTarget()(e,tp,eg,ep,ev,re,r,rp,0)) then
					table.insert(flip,ce)
				end
			end
			if #flip<=0 then return end
			local effect=flip[1]
			if #flip>1 then
				local desc={}
				for i=1,#flip do
					local ce=flip[i]
					table.insert(desc,ce:GetDescription())
				end
				effect=flip[Duel.SelectOption(tp,table.unpack(flip))+1]
			end
			if not effect then return end
			e:SetProperty(effect:GetProperty())
			if effect:GetTarget() then
				effect:GetTarget()(e,tp,eg,ep,ev,re,r,rp,1)
			end
			cid.effect_memory=effect
			table.insert(cid.name_list,tc:GetCode())
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function cid.flipop(e,tp,eg,ep,ev,re,r,rp)
	local ce=cid.effect_memory
	if ce and ce~=nil then
		local run=pcall(ce:GetOperation()(e,tp,eg,ep,ev,re,r,rp),e,tp,eg,ep,ev,re,r,rp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_REMOVED,0,nil):RandomSelect(tp,1)
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end

--SPSUMMON
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFacedown()
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) or e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local op
	if c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then
		op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
	elseif c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) then
		op=Duel.SelectOption(tp,aux.Stringid(id,3))
	elseif c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then
		op=Duel.SelectOption(tp,aux.Stringid(id,4))+1
	else
		return
	end
	local pos={POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE}
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,pos[op+1]) then
		if c:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			c:RegisterEffect(e2,true)
		end
	end
	Duel.SpecialSummonComplete()
end

--APPLY EFFECT
function cid.disrmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,5)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==5
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5
	end
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function cid.disrmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=e:GetHandler():IsCanTurnSet()
	local b2=Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
end
function cid.disrmop(e,tp,eg,ep,ev,re,r,rp)
	local b1=(e:GetHandler():IsCanTurnSet() and e:GetHandler():IsFaceup())
	local b2=Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
	local op=0
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,6),aux.Stringid(id,7))
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(id,6))
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(id,7))+1
	else return end
	if op==0 then
		Duel.ChangePosition(e:GetHandler(),POS_FACEDOWN_DEFENSE)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil):RandomSelect(tp,1)
		if #g<=0 then return end
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end