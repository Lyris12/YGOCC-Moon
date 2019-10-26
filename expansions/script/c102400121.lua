--created & coded by Lyris
--機夜光襲雷竜－ビッグバン・エオン
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,cid.ffilter,2,true)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(1118)
	e0:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_ATTACK)
	e0:SetCondition(cid.descon)
	e0:SetTarget(cid.destg)
	e0:SetOperation(cid.desop)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cid.tgcon)
	e1:SetValue(cid.etarget)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(1131)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_TODECK)
	e3:SetCondition(cid.discon)
	e3:SetTarget(cid.distg)
	e3:SetOperation(cid.negop)
	c:RegisterEffect(e3)
end
function cid.ffilter(c,fc,sub,mg,sg)
	return c:IsSetCard(0x7c4) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:IsExists(cid.fcheck,1,c,c:GetAttack()))
end
function cid.fcheck(c,atk)
	local dif=math.abs(c:GetAttack()-atk)
	return dif>0 and dif<=400
end
function cid.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP() or (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
function cid.desfilter(c,e,tp)
	return c:IsLevelBelow(5) and c:IsSetCard(0x7c4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ch=Duel.GetCurrentChain()
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and (ch==0
		or Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER)~=tp) and Duel.GetTurnPlayer()~=tp
		and Duel.IsExistingMatchingCard(cid.desfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		if Duel.GetAttacker() then Duel.NegateAttack()
		else
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_ATTACK_ANNOUNCE)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetOperation(cid.disop)
			Duel.RegisterEffect(e1,tp)
		end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.desfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateAttack()
end
function cid.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c4) and c:IsLevelBelow(5)
end
function cid.tgcon(e)
	return Duel.IsExistingMatchingCard(cid.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function cid.etarget(e,re)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(e:GetHandler())
end
function cid.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsChainDisablable(ev)
end
function cid.filter(c)
	return c:IsSetCard(0x7c4) and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck()
end
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local ct=1
	if re:GetHandler():IsAbleToDeck() and re:GetHandler():IsRelateToEffect(re) then
		ct=ct+1
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,ct,tp,LOCATION_GRAVE)
end
function cid.negop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cid.filter,tp,LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local dg=g:Select(tp,1,1,nil)
		Duel.SendtoDeck(eg+dg,nil,2,REASON_EFFECT)
	end
end
