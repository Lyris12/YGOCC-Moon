--created & coded by Lyris
--F・HEROデーンティー・ダイヤガイ
local cid,id=GetID()
function cid.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(cid.reg)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return r==REASON_FUSION end)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
function cid.reg(e,tp,eg,ep,ev,re,r,rp)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf7a))
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
end
function cid.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf7a) and c:IsAbleToDeck() and not c:IsCode(id)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return Duel.IsExistingTarget(cid.cfilter,tp,LOCATION_GRAVE,0,1,nil) and #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,Duel.SelectTarget(tp,cid.cfilter,tp,LOCATION_GRAVE,0,1,1,nil),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local tg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Select(tp,1,1,nil)
		if #tg>0 then
			Duel.BreakEffect()
			Duel.HintSelection(tg)
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end
