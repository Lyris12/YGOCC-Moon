--Ottavosigillo Shikijin
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	c:EnableReviveLimit()
	c:MustFirstBeSummoned(SUMMON_TYPE_DRIVE)
	--Drive Effects
	aux.AddDriveProc(c,16)
	local d1=c:DriveEffect(-20,0,nil,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.immtg,
		s.immop
	)
	local d2=c:OverDriveEffect(2,CATEGORY_TOGRAVE,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		aux.SendToGYTarget(aux.Filter(Card.IsSetCard,0x7ec,0x7ea),LOCATION_DECK,0,1),
		aux.SendToGYOperation(aux.Filter(Card.IsSetCard,0x7ec,0x7ea),LOCATION_DECK,0,1)
	)
	--Monster Effects
	--protection
	c:EffectProtection(PROTECTION_FROM_OPPONENT)
	c:TargetProtection(PROTECTION_FROM_OPPONENT)
	--destroy
	c:Ignition(3,CATEGORY_DAMAGE+CATEGORY_DESTROY,nil,LOCATION_MZONE,1,
		nil,
		nil,
		s.damtg,
		s.damop
	)
	--add to hand
	c:SentToGYTrigger(false,4,CATEGORY_TOHAND,true,nil,
		aux.DueToHavingZeroEnergyCond,
		aux.DiscardCost(aux.Filter(Card.IsSetCard,0x7ea)),
		aux.SendToHandTarget(SUBJECT_THIS_CARD),
		aux.SendToHandOperation(SUBJECT_THIS_CARD)
	)
end
function s.immtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.PlayerHasFlagEffect(tp,id) end
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x7ec))
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end

function s.desfilter(c,val)
	return c:IsFaceup() and c:GetAttack()<val
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x7ea)
	if chk==0 then return #g>0 end
	local ct=#g*300
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct)
	local sg=Duel.Group(s.desfilter,tp,0,LOCATION_MZONE,nil,ct)
	if #sg>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,1-tp,LOCATION_MZONE)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x7ea)
	if #g<=0 then return end
	local dam=Duel.Damage(1-tp,#g*300,REASON_EFFECT)
	if dam>0 then
		local sg=Duel.Group(s.desfilter,tp,0,LOCATION_MZONE,nil,dam)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end