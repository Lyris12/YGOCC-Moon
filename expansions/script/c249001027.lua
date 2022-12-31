--Pendulum-Angel's Song
function c249001027.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,249001027+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c249001027.target)
	e1:SetOperation(c249001027.activate)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c249001027.reptg)
	e2:SetValue(c249001027.repval)
	e2:SetOperation(c249001027.repop)
	c:RegisterEffect(e2)
end
function c249001027.filter1(c,e,tp)
	return c:IsSetCard(0x1B7) and c:IsType(TYPE_PENDULUM)
		and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false)) and Duel.IsExistingMatchingCard(c249001027.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function c249001027.filter2(c,e,tp,code)
	return c:IsSetCard(0x1B7) and c:IsType(TYPE_PENDULUM)
		and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false)) and c:GetCode()~=code
end
function c249001027.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001027.filter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c249001027.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(c249001027.filter1,tp,LOCATION_DECK,0,1,nil,e,tp) then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g1=Duel.SelectMatchingCard(tp,c249001027.filter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g2=Duel.SelectMatchingCard(tp,c249001027.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,g1:GetFirst():GetCode())
	g1:Merge(g2)
	Duel.ConfirmCards(1-tp,g1)
	Duel.ShuffleDeck(tp)
	local cg=g1:Select(1-tp,1,1,nil)
	local tc=cg:GetFirst()
	Duel.Hint(HINT_CARD,0,tc:GetCode())
	local option
	if tc:IsAbleToHand() then option=0 end
	if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then option=1 end
	if tc:IsAbleToHand() and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then option=Duel.SelectOption(tp,1152,1190) end
	if option > 0 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	else
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	g1:RemoveCard(tc)
	Duel.SendtoExtraP(g1,nil,REASON_EFFECT)
end
function c249001027.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(0x1B7)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function c249001027.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c249001027.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function c249001027.repval(e,c)
	return c39996157.repfilter(c,e:GetHandlerPlayer())
end
function c249001027.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end