--Leggenda Bushido Harambe
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x4b0),4,2)
	--protection
	c:UnaffectedProtection(s.efilter)
	--selfdestroy
	c:PhaseTrigger(true,PHASE_STANDBY,0,{CATEGORY_DESTROY,CATEGORY_DETACH},nil,LOCATION_MZONE,nil,
		aux.TurnPlayerCond(0),
		nil,
		s.destg,
		s.desop
	)
	--attach
	c:PhaseTrigger(false,PHASE_END,2,{0,CATEGORY_ATTACH},nil,LOCATION_MZONE,nil,
		aux.TurnPlayerCond(0),
		nil,
		aux.AttachTarget(aux.MonsterFilter(Card.IsSetCard,0x4b0),LOCATION_HAND,0,1,nil,SUBJECT_THIS_CARD),
		aux.AttachOperation(aux.MonsterFilter(Card.IsSetCard,0x4b0),LOCATION_HAND,0,1,1,nil,SUBJECT_THIS_CARD)
	)
	--destroy
	c:Ignition(3,CATEGORY_DESTROY,nil,LOCATION_MZONE,1,
		nil,
		aux.DetachSelfCost(),
		s.destg2,
		s.desop2
	)
	--take card
	c:SentToGYTrigger(false,4,CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON,true,true,
		nil,
		nil,
		s.thtg,
		s.thop)
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and (tc:IsSummonType(SUMMON_TYPE_SPECIAL) or te:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL))
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	if c:GetOverlayCount()<=0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,c:GetControler(),c:GetLocation())
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToChain() then return end
	if c:GetOverlayCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) and c:RemoveOverlayCard(tp,1,1,REASON_EFFECT) then
		Duel.AdjustInstantly(c)
	else
		Duel.Destroy(c,REASON_EFFECT)
	end
end

function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g1>0 and #g2>0 end
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.check(sg)
	return sg:GetClassCount(Card.GetControler)==#sg
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	local sg=g:SelectSubGroup(tp,s.check,false,2,2)
	if #sg==2 then
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

function s.thfilter(c,ft,e,tp)
	return c:IsMonster() and c:IsSetCard(0x4b0)
		and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,ft,e,tp)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,ft,e,tp):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function(sc)
			return ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function(sc)
			return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,5))
end