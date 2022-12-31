--Nonosigillo Shikinokami
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	c:EnableReviveLimit()
	c:MustFirstBeSummoned(SUMMON_TYPE_DRIVE)
	--Drive Effects
	aux.AddDriveProc(c,18)
	local d1=c:DriveEffect(-5,0,CATEGORY_TOHAND+CATEGORY_RECOVER,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		aux.Target(s.thfilter,LOCATION_MZONE,0,1,1,nil,nil,CATEGORY_TOHAND,nil,nil,aux.RecoverInfo(0,1800)),
		s.thop
	)
	local d2=c:OverDriveEffect(1,CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.sptg,
		s.spop
	)
	--Monster Effects
	--protection
	c:EffectProtectionField(nil,nil,LOCATION_MZONE,0,aux.TargetBoolFunction(Card.IsSetCard,0x7ec))
	--negate
	c:Quick(false,2,CATEGORY_DISABLE,nil,EVENT_CHAINING,LOCATION_MZONE,1,
		s.discon,
		s.discost,
		aux.DisableTarget(nil,0,LOCATION_ONFIELD,1),
		aux.DisableOperation(nil,0,LOCATION_ONFIELD,1,1,nil,RESET_PHASE+PHASE_END)
	)
	--add to hand
	c:SentToGYTrigger(false,3,CATEGORY_TOHAND,true,nil,
		aux.DueToHavingZeroEnergyCond,
		aux.DiscardCost(aux.Filter(Card.IsSetCard,0x7ea,0x7ec)),
		aux.SendToHandTarget(SUBJECT_THIS_CARD),
		aux.SendToHandOperation(SUBJECT_THIS_CARD)
	)
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7ec) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		Duel.BreakEffect()
		Duel.Recover(tp,1800,REASON_EFFECT)
	end
end

function s.spfilter(c,e,tp,necrovalley,ign)
	local f=s.rtfilter
	if necrovalley then f=aux.NecroValleyFilter(f) end
	return c:IsSetCard(0x7ec) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (ign or Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,0,1,c))
end
function s.rtfilter(c)
	return c:IsSetCard(0x7ea) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,true)
	if #g==0 then
		g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,nil,true)
	end
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local sg=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.NecroValleyFilter(s.rtfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if #sg>0 then
			Duel.Search(sg,tp)
		end
	end
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then return en and en:IsCanUpdateEnergy(-2,tp,REASON_COST) end
	en:UpdateEnergy(-2,tp,REASON_COST,true,e:GetHandler())
end