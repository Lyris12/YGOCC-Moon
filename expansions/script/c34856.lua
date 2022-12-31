--Iperdrive dal Paradiso
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--activate
	c:Activate()
	--boost
	c:UpdateATKDEFField(300,300,nil,LOCATION_MZONE,0,aux.TargetBoolFunction(Card.IsType,TYPE_DRIVE))
	--search
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:HOPT()
	e1:SetCost(aux.DiscardCost(nil,1,1))
	e1:SetTarget(aux.SearchTarget(s.filter,1,LOCATION_DECK+LOCATION_GRAVE))
	e1:SetOperation(aux.SearchOperation(s.filter,LOCATION_DECK+LOCATION_GRAVE,0,1,1))
	c:RegisterEffect(e1)
	--retrieve
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:HOPT()
	e3:SetCondition(s.rthcond)
	e3:SetCost(s.rthcost)
	e3:SetTarget(s.rthtg)
	e3:SetOperation(s.rthop)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsMonster() and c:IsSetCard(0x48a)
end

function s.egfilter(c,tp)
	return c:IsMonster(TYPE_DRIVE) and c:IsPreviousControler(tp) and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED+LOCATION_EXTRA) and c:IsFaceup()))
end
function s.rthcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.egfilter,1,nil,tp)
end
function s.rthcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.egfilter,nil,tp)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,g) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,1,g)
	if #sg>0 then
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
	end
end
function s.thfil(c,tp)
	return c:IsAbleToHand() and c:IsCanEngage(tp)
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.egfilter,nil,tp):Filter(s.thfil,nil,tp)
	if chk==0 then return #g>0 end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,g,1,0,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToChain() then return end
	local g=eg:Filter(s.egfilter,nil,tp):Filter(Card.IsAbleToHand,nil):Filter(Card.IsRelateToChain,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		local tc=sg:GetFirst()
		if Duel.Search(sg,tp) then
			tc:Engage(e,tp)
		end
	end
end