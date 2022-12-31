--MMS - Tifone, Progenitore dei Mostri
--Script by XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	--destroy backrow
	c:SummonedTrigger(false,false,true,false,0,CATEGORY_DESTROY,true,true,
		nil,
		nil,
		aux.DestroyTarget({SUBJECT_ALL,Card.IsSpellTrapOnField},0,LOCATION_ONFIELD),
		aux.DestroyOperation({SUBJECT_ALL,Card.IsSpellTrapOnField},0,LOCATION_ONFIELD)
	)
	--destroy monsters
	c:DeclaredAttackTrigger(false,1,CATEGORY_DESTROY,true,true,
		nil,
		nil,
		s.target,
		s.operation
	)
	--search
	c:DestroyedAndSentToGYTrigger(false,2,CATEGORY_SEARCH+CATEGORY_TOHAND,true,true,
		aux.ByPlayerCardCond(1),
		aux.BanishFacedownSelfCost,
		aux.SearchTarget(aux.Filter(Card.IsCode,CARD_SUPER_POLYMERIZATION)),
		aux.SearchOperation(aux.Filter(Card.IsCode,CARD_SUPER_POLYMERIZATION))
	)
end
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionType(TYPE_MONSTER) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
		and (not mg or #mg<3 or mg:IsExists(s.includefilter,1,nil))
end
function s.includefilter(c)
	return c:IsLevelAbove(6) and c:IsFusionSetCard(0xd71)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if chk==0 then return Duel.IsBattlePhase() and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,1-tp,LOCATION_MZONE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsBattlePhase() then return end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	Duel.Destroy(g,REASON_EFFECT)
end

function s.thfilter(c,e,tp)
	return c:IsFaceup() and c:IsST(TYPE_CONTINUOUS+TYPE_FIELD) and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end