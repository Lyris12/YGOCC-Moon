--created & coded by Lyris
--半物質のイーグル
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigSpatialType(c)
	aux.AddSpatialProc(c,aux.drccheck,aux.FilterBoolFunction(aux.NOT(Card.IsType),TYPE_TOKEN),2,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if not rc then if re then rc=re:GetHandler()
	else rc=c:GetReasonEffect():GetHandler() end end
	return c:IsReason(REASON_BATTLE) or rp~=tp or rp==tp and rc and rc:IsSetCard(0xf87)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
end
