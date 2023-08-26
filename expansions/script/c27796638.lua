--Abysslym - Ragnaline Susano'o
--Script by TaxingCorn117

local s,id=GetID()
function s.initial_effect(c)
    --link summon
    aux.AddLinkProcedure(c,s.matfilter,2,2)
    c:EnableReviveLimit()
    --draw
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(aux.DrawOperation())
    c:RegisterEffect(e1)
    --destroy
    local e2=Effect.CreateEffect(c)
	e2:Desc(1)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:OPT()
    e2:SetCost(aux.DummyCost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end
function s.matfilter(c)
    return c:IsLinkSetCard(ARCHE_ABYSSLYM) and not c:IsLinkCode(id)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.cfilter(c)
    return c:IsSetCard(ARCHE_ABYSSLYM) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil)
	end
	local ct=2
	if Duel.GetDeckCount(tp)==2 then
		ct=1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,ct,nil)
    if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.rmfilter(c)
    return c:IsSetCard(ARCHE_ABYSSLYM) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
		return e:IsCostChecked() and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	end
	local fg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if #fg<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,math.min(#fg,3),nil)
    if #g>0 then
		local ct=Duel.Remove(g,POS_FACEUP,REASON_COST)
		e:SetLabel(ct)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,e:GetLabel(),1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    if ct==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,ct,ct,nil)
    if g:GetCount()>0 then
        Duel.HintSelection(g)
        Duel.Destroy(g,REASON_EFFECT)
    end
end