--created & coded by Lyris
--フェイツ・ブルーＬｉｇｈｔ－９
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cid.damcon)
	e1:SetTarget(cid.damtg)
	e1:SetOperation(cid.damop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.activate)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(function(e,tp) return not Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,1,nil) end)
	c:RegisterEffect(e3)
end
function cid.filter(c)
	return c:IsSetCard(0xf7a) and c:GetType()&0x82==0x82 and c:IsAbleToDeck() and c:CheckActivateEffect(true,true,false)~=nil
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(g:Filter(Card.IsLocation,nil,LOCATION_GRAVE))
	Duel.ConfirmCards(1-tp,g:Filter(Card.IsLocation,nil,LOCATION_HAND))
	local tc=g:GetFirst()
	if #g==0 or Duel.SendtoDeck(g,nil,2,REASON_EFFECT)==0 then return end
	Duel.ShuffleDeck(tp)
	Duel.BreakEffect()
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(true,true,true)
	tc:CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function cid.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function cid.dfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:GetAttack()>0
end
function cid.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return ((chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp))
		or (chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp))) and cid.dfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.dfilter,tp,LOCATION_MZONE,LOCATION_GRAVE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cid.dfilter,tp,LOCATION_MZONE,LOCATION_GRAVE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
function cid.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
