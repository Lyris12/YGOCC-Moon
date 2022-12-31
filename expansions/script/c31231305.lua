--Freja, Cascad Lieutenant
--Script by XGlitchy30
function c31231305.initial_effect(c)
	--recover resources
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31231305,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,31231305)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetTarget(c31231305.tgtg)
	e1:SetOperation(c31231305.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--topdeck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31231305,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_REMOVE)
	e4:SetCountLimit(1,31231205)
	e4:SetCondition(c31231305.tdcon)
	e4:SetTarget(c31231305.tdtg)
	e4:SetOperation(c31231305.tdop)
	c:RegisterEffect(e4)
end
--filters
function c31231305.tgfilter(c)
	return c:IsRace(RACE_AQUA) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function c31231305.tdfilter(c)
	return aux.IsCodeListed(c,31231300) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
--recover resources
function c31231305.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31231305.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c31231305.tgfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c31231305.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetFirst():IsSetCard(0x3233) and g:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
function c31231305.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:IsSetCard(0x3233) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			if Duel.SelectYesNo(tp,aux.Stringid(31231305,1)) then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			else
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
			end
		else
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
--topdeck
function c31231305.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
function c31231305.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31231305.tdfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c31231305.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(16693254,1))
	local g=Duel.SelectMatchingCard(tp,c31231305.tdfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
	end
end