--Monkastery Arte - Skysplit
local ref,id=GetID()
Duel.LoadScript("Monkastery.lua")
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
	e1:SetCost(ref.actcost)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--Continue
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(ref.destg)
	e2:SetOperation(ref.desop)
	c:RegisterEffect(e2)
end

--Activate
function ref.actcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and (re:IsHasType(EFFECT_TYPE_QUICK_O) or re:IsHasType(EFFECT_TYPE_QUICK_F))
end
function ref.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST)
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #mg>1 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,mg,math.floor(#mg/2),1-tp,LOCATION_ONFIELD)
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_ONFIELD,0,nil)
	local ct=math.floor(#g/2)
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,ct,ct,nil)
		Duel.HintSelection(sg)
		Duel.SendtoGrave(sg,REASON_RULE)
	end
end

--Continue
function ref.descfilter(c,tp)
	return Monkastery.UsedFilter(c,id)
		and (Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil)
		or Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,bit.band(c:GetOriginalType(),TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)))
end
function ref.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and ref.descfilter(chkc,tp) end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0 and Duel.IsExistingTarget(ref.descfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,ref.descfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,LOCATION_GRAVE)
end
function ref.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	local rg=g:Filter(Card.IsFacedown,nil)
	if #rg>0 then Duel.ConfirmCards(tp,rg) end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local typ=bit.band(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,tc:GetOriginalType())
		local desg=g:Filter(Card.IsType,nil,typ)
		if #desg>0 then
			local sg=desg:Select(tp,1,1,nil)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
