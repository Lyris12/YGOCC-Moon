--MMS - Galaxy Seeker
--MMS - Cercatore Galattico
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--If you control no monsters: You can Special Summon this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(s.hspcon,nil,s.hsptg,s.hspop)
	c:RegisterEffect(e1)
	--You can banish 1 card from your hand; add 1 "MMS -", "Photon", or "Galaxy" monster, from your Deck to your hand.
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(nil,aux.BanishCost(nil,LOCATION_HAND),s.thtg,s.thop)
	c:RegisterEffect(e2)
end
--E1
function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_MMS,ARCHE_PHOTON,ARCHE_GALAXY) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end