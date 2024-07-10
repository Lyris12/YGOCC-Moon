--[[
Automatyrant Core
Automatiranno Nucleo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[During your Main Phase: You can send the top 3 cards of your Deck to the GY; Special Summon this card from your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		aux.MainPhaseCond(0),
		s.cost,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can add 1 "Automatyrant" card from your Deck or GY to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.thtg,s.thop)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[If this card is sent to the GY: You can target 1 "Automatyrant" card in your GY, except this card; add it to your hand.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:HOPT()
	e3:SetFunctions(nil,nil,s.thtg2,s.thop2)
	c:RegisterEffect(e3)
end
--E1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) end
	Duel.DiscardDeck(tp,3,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

--E2
function s.filter(c)
	return c:IsSetCard(ARCHE_AUTOMATYRANT) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end

--E3
function s.thfilter(c)
	return c:IsSetCard(ARCHE_AUTOMATYRANT) and c:IsAbleToHand()
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc~=aux.ExceptThis(c) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.Search(tc)
	end
end