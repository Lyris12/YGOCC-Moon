--Shyan Deity - Spirit Shard
function c11000537.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,c11000537.mfilter,1,1)
	c:EnableReviveLimit()
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11000537,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,11000537)
	e1:SetCondition(c11000537.thcon)
	e1:SetTarget(c11000537.thtg)
	e1:SetOperation(c11000537.thop)
	c:RegisterEffect(e1)
	--Discard to Extra Normal
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11000537,1))
	e2:SetCategory(CATEGORY_SUMMON+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,11001537)
	e2:SetTarget(c11000537.sumtg)
	e2:SetOperation(c11000537.sumop)
	c:RegisterEffect(e2)
end
function c11000537.mfilter(c)
	return c:IsSetCard(0x1FD) or c:IsSetCard(0x1F3)
end
function c11000537.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c11000537.thfilter(c)
	return c:IsCode(11000510) and c:IsAbleToHand()
end
function c11000537.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11000537.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c11000537.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c11000537.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c11000537.sumfilter(c)
	return c:IsSetCard(0x1FD) and c:IsSummonable(true,nil)
end
function c11000537.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11000537.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function c11000537.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)==0 then return end
	if Duel.IsExistingMatchingCard(c11000537.sumfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(11000537,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local g=Duel.SelectMatchingCard(tp,c11000537.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.Summon(tp,g:GetFirst(),true,nil)
		end
	end
end
