--Dracosis Strixel
local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(s.descon)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x300) and c:GetBattleTarget():IsControler(1-tp)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a or not a:IsRelateToBattle() or not d or not d:IsRelateToBattle() then return end
	return Group.FromCards(a,d):IsExists(s.filter,1,nil,tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.descon(e,tp,eg,ep,ev,re,r,rp) end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	Duel.SetTargetCard(g)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if g:FilterCount(Card.IsRelateToBattle,nil)~=2 then return end
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
