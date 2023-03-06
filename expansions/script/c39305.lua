--Starforce Ultra Dude Knight

local s,id=GetID()
function s.initial_effect(c)
	aux.AddFusionProcCode2(c,CARD_STARFORCE_KNIGHT,id-1,true,true)
	c:EnableReviveLimit()
	--Remove
	local e3=Effect.CreateEffect(c)
	e3:Desc(0)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	e3:SetCountLimit(1)
	c:RegisterEffect(e3)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsSpellTrapOnField() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
