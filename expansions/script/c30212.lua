--Mantra Beast
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:IsSetCard(0x7d0) or (tc:GetCode()>30200 and tc:GetCode()<30230) end)
	--Xyz Summon
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,Card.IsMantra,4,2)
	--Send
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(s_id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(scard.cost)
	e1:SetTarget(scard.tar)
	e1:SetOperation(scard.activate)
	e1:SetCountLimit(1,s_id)
	c:RegisterEffect(e1)
	--Recover
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(s_id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(scard.cost)
	e2:SetTarget(scard.target)
	e2:SetOperation(scard.operation)
	e2:SetCountLimit(1,s_id)
	c:RegisterEffect(e2)
end
function scard.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function scard.filter(c)
	return c:IsMantra() and c:IsAbleToGrave()
end
function scard.tar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(scard.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function scard.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,scard.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local sg=g:GetFirst()
		if Duel.SendtoGrave(g,REASON_EFFECT)>0 and sg:IsLocation(LOCATION_GRAVE) and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)>0
		and Duel.SelectYesNo(tp,aux.Stringid(s_id,3)) then
			local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
			local tc=g:GetFirst()
			if tc then
				Duel.HintSelection(g)
				Duel.BreakEffect()
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(-1000)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				tc:RegisterEffect(e2)
			end
		end
	end
end

function scard.handfilter(c)
	return c:NotBanishedOrFaceup() and c:IsMonster() and c:IsMantra() and not c:IsType(TYPE_XYZ) and c:IsAbleToHand()
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and scard.handfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(scard.handfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,scard.handfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SetCardOperationInfo(g:GetFirst(),CATEGORY_TOHAND)
end
function scard.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToChain() and scard.handfilter(tc) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and aux.PLChk(tc,tp,LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,Group.FromCards(tc))
		if tc:IsMonster() and tc:IsAttribute(ATTRIBUTE_DARK) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(s_id,2)) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
