--Distruzione tramite Automazione
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,2)
	local d1=c:DriveEffect(0,0,CATEGORY_DESTROY,EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY,EVENT_ENGAGE,
		nil,
		nil,
		aux.Target(Card.IsFaceup,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,nil,CATEGORY_DESTROY),
		aux.DestroyOperation({SUBJECT_THAT_TARGET,Card.IsFaceup})
	)
	local d2=c:DriveEffect(3,1,CATEGORY_DESTROY+CATEGORY_DAMAGE,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.destg,
		s.desop
	)
	--Monster Effects
	--negate
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.DriveSummonedCond)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:HOPT()
	e2:SetCondition(aux.bdgcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--search 2
	c:SentToGYTrigger(false,4,CATEGORY_TOHAND,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY,true,
		s.thcon,
		nil,
		aux.Target(s.filter,LOCATION_GRAVE,0,1,1,nil,nil,CATEGORY_TOHAND),
		aux.SendToHandOperation(SUBJECT_IT)
	)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_FIRE),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_FIRE),tp,LOCATION_MZONE,0,1,1,nil)
	if #g<=0 then return end
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	if Duel.Destroy(tc,REASON_EFFECT)>0 then
		local value=tc:GetBaseAttack()
		if value>0 then
			Duel.Damage(1-tp,value,REASON_EFFECT)
		end
	end
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,1-tp,LOCATION_MZONE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		Duel.Negate(tc,e)
	end
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	Duel.SetTargetCard(bc)
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetAttack()
		if dam<0 then dam=0 end
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():HasFlagEffect(FLAG_ZERO_ENERGY)
end
function s.filter(c)
	return c:IsMonster() and not c:IsType(TYPE_DRIVE) and c:IsAbleToHand()
end