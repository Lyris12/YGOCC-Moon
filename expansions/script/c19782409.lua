--created by ZEN, coded by ZEN & Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:GLString(1)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:GLString(2)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_LEAVE_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetTarget(cid.tg)
	e2:SetOperation(cid.op)
	c:RegisterEffect(e2)
end
function cid.filter1(c)
	return c:IsSetCard(0xd7c) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>(e:GetHandler():IsLocation(LOCATION_HAND) and 3 or 2)
		and Duel.IsExistingMatchingCard(cid.filter1,tp,LOCATION_DECK,0,3,nil)
	end
	if Duel.GetMatchingGroupCount(nil,tp,LOCATION_ONFIELD,0,e:GetHandler())==0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(function(e,rpr,tpr) return rpr==tpr end)
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=2 then return end
	local evg=Group.CreateGroup()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local g=Duel.SelectMatchingCard(tp,cid.filter1,tp,LOCATION_DECK,0,3,3,nil)
	for c in aux.Next(g) do
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		if c:IsLocation(LOCATION_SZONE) and c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) then
			evg:AddCard(c)
		end
	end
	if #evg>0 then
		Duel.RaiseEvent(evg,EVENT_CUSTOM+id-1,e,r,tp,tp,0)
	end
end
function cid.filter2(c,tp)
	return c:IsSetCard(0xd7c) and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not c:IsForbidden()))
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.filter2(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingTarget(cid.filter2,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(cid.filter2),tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SendtoDeck(c,nil,2,REASON_EFFECT)==0 or not c:IsLocation(LOCATION_DECK) then return end
	Duel.ShuffleDeck(tp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not cid.filter2(tc,tp) then return end
	local b1,b2=tc:IsAbleToHand(),(Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not tc:IsForbidden())
	if b2 and (not b1 or Duel.SelectOption(tp,1190,1051)==1) then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:GLString(0)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		Duel.RaiseEvent(tc,EVENT_CUSTOM+id-1,e,r,tp,tp,0)
	else
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
