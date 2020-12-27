--ESPergear Armor Break
function c16000037.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,16000037+EFFECT_COUNT_CODE_OATH)
	--e1:SetTarget(c16000037.target)
	e1:SetOperation(c16000037.activate)
	c:RegisterEffect(e1)
		--tohand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16000037,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,16000037)
	e3:SetTarget(c16000037.thtg)
	e3:SetOperation(c16000037.thop)
	c:RegisterEffect(e3)
end
function c16000037.filter(c)
	return c:IsSetCard(0x668f) and c:IsType(TYPE_MONSTER)  and c:IsAbleToHand()
end
function c16000037.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c16000037.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(16000037,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c16000037.spfilter2(c,e,tp)
	return c:IsSetCard(0x667f) and c:IsType(TYPE_MONSTER)-- and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c16000037.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(c16000037.spfilter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=3
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function c16000037.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c16000037.spfilter2,tp,LOCATION_DECK,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local cg=g:SelectSubGroup(tp,aux.dncheck,3,3)
	if cg:GetCount()>=3 then
		Duel.ConfirmCards(1-tp,cg)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local tg=cg:Select(1-tp,1,1,nil)
		local tc=tg:GetFirst()
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			cg:RemoveCard(tc)
		end
		local tg=cg:GetFirst()
		Duel.SortDecktop(tp,tp,cg:GetCount())
		for i=1,cg:GetCount() do
			local mg=Duel.GetDecktopGroup(tp,1)
			Duel.MoveSequence(mg:GetFirst(),1)
		end
	end
end
