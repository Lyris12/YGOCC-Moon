--Gorgeous Gift of Heaven - The Godspark
function c4200100.initial_effect(c)
--Search
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(4200100,0))
e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetTarget(c4200100.st)
e1:SetOperation(c4200100.sa)
e1:SetCountLimit(1,4200100)
c:RegisterEffect(e1)
--SS A Godspark with different type and attribute
local e2=Effect.CreateEffect(c)
e2:SetDescription(aux.Stringid(4200100,1))
e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
e2:SetType(EFFECT_TYPE_ACTIVATE)
e2:SetCode(EVENT_FREE_CHAIN)
e2:SetTarget(c4200100.spt)
e2:SetOperation(c4200100.spo)
e2:SetCountLimit(1,4200100+1000)
c:RegisterEffect(e2)
end
function c4200100.thfilter(c)
return c:IsSetCard(0x412) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
	function c4200100.st(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c4200100.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c4200100.sa(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.GetFirstTarget()
	local g=Duel.SelectMatchingCard(tp,c4200100.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		end
		end
function c4200100.diffilter(c,att,rac)
return c:IsFaceup() and c:IsAttribute(att) and c:IsRace(rac)
end
function c4200100.ssfilter(c,e,tp)
return c:IsSetCard(0x412) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
and not Duel.IsExistingMatchingCard(c4200100.diffilter,tp,LOCATION_MZONE,0,1,nil,c:GetAttribute(),c:GetRace())
end
function c4200100.spt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c4200100.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c4200100.spo(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,c4200100.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if tc:GetCount()>0 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
	