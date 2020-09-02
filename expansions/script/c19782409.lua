--created by ZEN, coded by ZEN & Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,aux.FilterBoolFunction(Card.IsSetCard,0xd7c))
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,aux.FilterBoolFunction(Card.IsSetCard,0xd7c))
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e2:SetCondition(aux.exccon)
	e2:SetTarget(cid.tg)
	e2:SetOperation(cid.op)
	c:RegisterEffect(e2)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
end
function cid.filter1(c)
	return c:IsSetCard(0xd7c) and c:IsAbleToHand()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>(e:GetHandler():IsLocation(LOCATION_HAND) and 3 or 2)
		and Duel.IsExistingMatchingCard(cid.filter1,tp,LOCATION_DECK,0,3,nil) end
	if Duel.GetMatchingGroupCount(nil,tp,LOCATION_ONFIELD,0,e:GetHandler())==0
		and e:IsHasType(EFFECT_TYPE_ACTIVATE) then Duel.SetChainLimit(function(e,rpr,tpr) return rpr==tpr end) end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local g=Duel.SelectMatchingCard(tp,cid.filter1,tp,LOCATION_DECK,0,3,3,nil)
	for c in aux.Next(g) do
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SINGLE_RANGE)
		e1:SetReset(RESET_EVENT+0x1fc0000)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
	Duel.RaiseEvent(g,EVENT_CUSTOM+id-1,e,r,tp,tp,0)
end
function cid.filter2(c,tp)
	return c:IsSetCard(0xd7c) and (c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not c:IsForbidden())
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.filter2(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingTarget(cid.filter2,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	Duel.SelectTarget(tp,cid.filter2,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SendtoDeck(c,nil,2,REASON_EFFECT)==0
		or not c:IsLocation(LOCATION_DECK) then return end
	Duel.ShuffleDeck(tp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not cid.filter2(tc,tp) then return end
	local b1,b2=tc:IsAbleToHand(),Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not tc:IsForbidden()
	if b2 and (not b1 or Duel.SelectOption(tp,1190,1051)==1) then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		Duel.RaiseEvent(tc,EVENT_CUSTOM+id-1,e,r,tp,tp,0)
	else Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
