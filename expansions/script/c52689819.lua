--Hyperdrive Brave
--Iperdrive Coraggio
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[While a player has an Engaged monster, this card is unaffected by your opponent's card effects.]]
	c:UnaffectedProtection(PROTECTION_FROM_OPPONENT,false,c,LOCATION_MZONE,aux.IsExistingEngagedCond())
	--[[At the start of the Battle Phase: You can target 1 card your opponent controls; destroy 1 "Hyperdrive" card in your hand or Deck, and if you do, destroy that target.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can make the Level of all Engaged monsters become equal to their current respective Energies (even after they are Summoned/Set).]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetCost(aux.LabelCost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.desfilter(c,tp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND|LOCATION_DECK,0,1,c,ARCHE_HYPERDRIVE)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	local sg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND|LOCATION_DECK,0,g,ARCHE_HYPERDRIVE)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,Card.IsSetCard,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,tc,ARCHE_HYPERDRIVE)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 and tc and tc:IsRelateToChain() and tc:IsControler(1-tp) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetBattleMonster(tp)
	return tc and tc:IsFaceup() and tc:IsSetCard(ARCHE_HYPERDRIVE)
end
function s.atkfilter(c)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return (a==c or (d and d==c)) and c:IsFaceup() and c:IsSetCard(ARCHE_HYPERDRIVE)
end
function s.resfilter(c)
	return c:IsRelateToBattle() and c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(ARCHE_HYPERDRIVE)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=Duel.GetEngagedCard(tp)
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		if not ec then return false end
		local check=false
		for ct=1,ec:GetEnergy() do
			if ec:IsCanUpdateEnergy(-ct,tp,REASON_COST,e) then
				check=true
				break
			end
		end
		return check and #g>0
	end
	e:SetLabel(0)
	local ct=Duel.AnnounceEnergyUpdate(tp,ec,nil,nil,nil,REASON_COST,e)
	local _,val=ec:UpdateEnergy(ct,tp,REASON_COST,true,e:GetHandler(),e)
	val=math.abs(val)
	
	Duel.SetTargetCard(g)
	Duel.SetTargetParam(val)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,LOCATION_MZONE,val*200)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local val=Duel.GetTargetParam()
	if not val then return end
	val=val*200
	local g=Duel.GetTargetCards():Filter(s.resfilter,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
		tc:RegisterEffect(e1)
	end
end