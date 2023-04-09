--Aethon Support Spirit
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--If a Beast monster(s) is Normal or Special Summoned to your field (except during the Damage Step): You can Special Summon this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--[[You can detach 1 material from a Beast Xyz Monster you control; add 1 Level 3 Beast monster from your Deck to your hand
	with a different Attribute than the monsters you control or in your GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.spfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_BEAST)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToChain() then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_XYZ) and c:IsRace(RACE_BEAST) and c:GetOverlayCount()>0
end
function s.costcheck(c,tp,g)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp,g,c)
end
function s.thfilter(c,tp,g,cg)
	if cg then
		g:AddCard(cg)
	end
	return c:IsMonster() and c:IsRace(RACE_BEAST) and c:IsAbleToHand() and not g:IsExists(Card.IsAttribute,1,nil,c:GetAttribute())
end
function s.attfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:GetAttribute()~=0
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local g=Group.CreateGroup()
	local attg=Duel.GetMatchingGroup(s.attfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(mg) do
		g:Merge(tc:GetOverlayGroup())
	end
	if chk==0 then return #g>0 and g:IsExists(s.costcheck,1,nil,tp,attg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local sg=g:FilterSelect(tp,s.costcheck,1,1,nil,tp,attg)
	Duel.SendtoGrave(sg,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			return true
		end
		e:SetLabel(0)
		local attg=Duel.GetMatchingGroup(s.attfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp,attg)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local attg=Duel.GetMatchingGroup(s.attfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp,attg)
	if #g>0 then
		Duel.Search(g,tp)
	end
end