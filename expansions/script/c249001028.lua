--Magic Pendulum Art - Attack Absorbtion Tuning
function c249001028.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c249001028.condition)
	e1:SetTarget(c249001028.target)
	e1:SetOperation(c249001028.activate)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36484016,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c249001028.drcon)
	e2:SetTarget(c249001028.drtg)
	e2:SetOperation(c249001028.drop)
	c:RegisterEffect(e2)
end
function c249001028.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x98)
end
function c249001028.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(c249001028.cfilter,tp,LOCATION_MZONE+LOCATION_PZONE+LOCATION_EXTRA,0,1,nil) then return false end 
	return Duel.GetAttacker():IsControler(1-tp) or Duel.GetAttackTarget():IsControler(1-tp)
end
function c249001028.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249001028.filter(c,e,tp,lv)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c249001028.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() then
		Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		if Duel.GetLocationCountFromEx(tp)<=0 or not Duel.SelectYesNo(tp,2) then return end
		local val=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetSum(Card.GetLevel)+(Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetSum(Card.GetRank)*2)+(Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetSum(Card.GetLink)*2)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001028.filter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp,val)
		local sc=g1:GetFirst()
		if sc then
			val=val-sc:GetLevel()
			if Duel.IsExistingMatchingCard(c249001028.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,sc,e,tp,val) and 
				Duel.GetLocationCountFromEx(tp)>1 and Duel.SelectYesNo(tp,2) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001028.filter),tp,LOCATION_EXTRA,0,1,1,sc,e,tp,val)
				g1:Merge(g2)
			end
			Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function c249001028.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT)==REASON_EFFECT and rp==1-tp and c:GetPreviousControler()==tp
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
function c249001028.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249001028.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end