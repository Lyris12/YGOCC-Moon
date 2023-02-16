--Mantra's Soul
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:IsSetCard(0x7d0) or (tc:GetCode()>30200 and tc:GetCode()<30230) end)
	c:SetUniqueOnField(1,0,s_id)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Recover
	aux.RegisterMergedDelayedEventGlitchy(c,s_id,EVENT_TO_GRAVE,scard.somefilter)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+s_id)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(scard.target)
	e1:SetOperation(scard.activate)
	e1:SetCountLimit(1,s_id)
	c:RegisterEffect(e1)
	
end
function scard.somefilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and rc:IsMantra() and c:IsReason(REASON_EFFECT|REASON_COST)
	and c:IsAttribute(ATTRIBUTE_DARK) and c:IsMantra()
	and c:GetPreviousControler()==tp and c:GetPreviousLocation()==LOCATION_HAND
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return eg:IsContains(chkc) end
    if chk==0 then return eg:IsExists(Card.IsCanBeEffectTarget,1,nil,e) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=eg:FilterSelect(tp,Card.IsCanBeEffectTarget,1,1,nil,e)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,LOCATION_GRAVE)
end
function scard.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards()
    if #g>0 then
		Duel.Search(g,tp)
	end
end
