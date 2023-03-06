--Starforce Knightmare

local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x24f),2,true)
	--extra summon
	local e3=Effect.CreateEffect(c)
	e3:Desc(0)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x24f))
	c:RegisterEffect(e3)
	--Remove
	local e4=Effect.CreateEffect(c)
	e4:Desc(1)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	e4:SetCountLimit(1)
	c:RegisterEffect(e4)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end
