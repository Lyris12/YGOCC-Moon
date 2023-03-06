--Starforce Ultra Hyper Knight

local s,id=GetID()
function s.initial_effect(c)
	aux.AddFusionProcCode2(c,CARD_STARFORCE_KNIGHT,id-1,true,true)
	c:EnableReviveLimit()
	--Remove
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsSetCard(0x24f) and c:IsAbleToHand() 
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
