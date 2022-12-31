--Sestosigillo Shikiogi
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	c:MustFirstBeSummoned(SUMMON_TYPE_DRIVE)
	c:EnableReviveLimit()
	--Drive Effects
	aux.AddDriveProc(c,12)
	local d1=c:DriveEffect(-7,0,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.sptg,
		s.spop
	)
	local d2=c:OverDriveEffect(1,CATEGORY_DAMAGE+CATEGORY_DESTROY,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.damtg,
		s.damop
	)
	--Monster Effects
	--boost
	c:UpdateATKDEFField(500,500,LOCATION_MZONE,LOCATION_MZONE,0,s.target)
	--search
	c:Ignition(3,CATEGORIES_SEARCH,nil,LOCATION_MZONE,1,
		nil,
		aux.DiscardCost(),
		s.thtg,
		s.thop
	)
	--add to hand
	c:SentToGYTrigger(false,4,CATEGORY_TOHAND,true,nil,
		aux.DueToHavingZeroEnergyCond,
		aux.DiscardCost(aux.Filter(Card.IsSetCard,0x7ea)),
		aux.SendToHandTarget(SUBJECT_THIS_CARD),
		aux.SendToHandOperation(SUBJECT_THIS_CARD)
	)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x7ec) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_HAND+LOCATION_GRAVE,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Damage(1-tp,500,REASON_EFFECT)>0 then
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.HintSelection(sg)
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end

function s.target(e,c)
	return c:IsSetCard(0x7eb,0x7ec) and c~=e:GetHandler()
end

function s.thfilter(c)
	return c:IsSetCard(0x7eb) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
			and (not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x7ec),tp,LOCATION_MZONE,0,1,nil) or Duel.IsPlayerCanDraw(tp,1))
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x7ec),tp,LOCATION_MZONE,0,1,nil) then
		e:SetCategory(CATEGORIES_SEARCH+CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		e:SetCategory(CATEGORIES_SEARCH)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x7ec),tp,LOCATION_MZONE,0,1,nil) then
			if Duel.IsPlayerCanDraw(tp,1) then
				Duel.BreakEffect()
			end
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end