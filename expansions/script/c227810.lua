--Time Angel, Walrus Edition
--Scripted by Walrus with assistance from APurpleApple
local s,id = GetID()

function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--shuffle
	local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
    e2:SetCost(aux.bfgcost)
    e2:SetCondition(s.gycon)
    e2:SetOperation(s.gyop)
    e2:SetTarget(s.gytar)
    c:RegisterEffect(e2)
end
--E1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.filter(c)
	return (c:IsSetCard(0x4a) or c:IsCode(27107590) or c:IsCode(9409625) or c:IsCode(36894320) or c:IsCode(72883039)) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--E2
function s.gytar(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil, TYPE_MONSTER):GetCount() > 0 end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND, nil, 0,0,0)
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.sfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
function s.sfilter(c,tp,rp)
    return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and bit.band(c:GetPreviousTypeOnField(),TYPE_MONSTER)~=0 and c:IsPreviousSetCard(0x4a) end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local tg = Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil, TYPE_MONSTER)
    Duel.SendtoHand(tg, nil, REASON_EFFECT)
end