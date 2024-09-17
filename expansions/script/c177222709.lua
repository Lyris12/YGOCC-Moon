--Foreseeing Pandemonium
local s,id,o=GetID()
function s.initial_effect(c)
	--Banish 1 face-up Pandemonium Monster you control or in your Extra Deck; add 2 monsters (1 from your GY and 1 from your Deck) with different Levels and whose Levels are equal to either of the banished monster's Pandemonium Scales.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetLabel(0)
	e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.costfilter(c)
	local lsc=c:GetLeftScale()
	local rsc=c:GetRightScale()
    return c:IsFaceup() and c:IsType(TYPE_PANDEMONIUM) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,lsc,rsc)
end

function s.thfilter(c,lsc,rsc)
    return c:IsMonster() and (c:GetLevel()==lsc or c:GetLevel()==rsc) and c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,lsc,rsc,c:GetLevel())
end

function s.thfilter2(c,lsc,rsc,level)
    return c:IsMonster() and (c:GetLevel()==lsc or c:GetLevel()==rsc) and c:IsAbleToHand() and c:GetLevel()~=level
end

function s.thfilter3(c,lsc,rsc)
    return c:IsMonster() and (c:GetLevel()==lsc or c:GetLevel()==rsc) and c:IsAbleToHand()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local lsc,rsc=e:GetLabel()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA+LOCATION_MZONE,0,1,nil)
	end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA+LOCATION_MZONE,0,1,1,nil)
    e:SetLabel(g:GetFirst():GetLeftScale(),g:GetFirst():GetRightScale())
    Duel.Remove(g,POS_FACEUP,REASON_COST)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.fselect(g)
	return g:GetClassCount(Card.GetLocation)==g:GetCount() and g:GetClassCount(Card.GetLevel)==g:GetCount()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local lsc,rsc=e:GetLabel()
    local g=Duel.GetMatchingGroup(s.thfilter3,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,lsc,rsc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2)
    if sg and #sg==2 then
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end
