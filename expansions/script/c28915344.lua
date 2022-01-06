--Basking Divexplorer, Golp
local ref,id=GetID()
function ref.initial_effect(c)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(ref.thtg)
	e1:SetOperation(ref.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Nom
	local ck1=Effect.CreateEffect(c)
	ck1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ck1:SetCode(EVENT_CHAINING)
	ck1:SetRange(LOCATION_REMOVED)
	ck1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	ck1:SetOperation(aux.chainreg)
	c:RegisterEffect(ck1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_REMOVED+LOCATION_HAND)
	e2:SetCountLimit(1,id+1000)
	e2:SetCondition(ref.sscon)
	e2:SetTarget(ref.sstg)
	e2:SetOperation(ref.ssop)
	c:RegisterEffect(e2)
end


--Search
function ref.thfilter(c)
	return c:IsSetCard(0x72e) and c:IsAbleToHand() and not c:IsCode(id)
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
	end
end

--Nom
function ref.sscon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local c=e:GetHandler()
	local seq=re:GetActivateSequence()
	return Duel.GetTurnPlayer()==tp and re:IsActivated()
		and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
		and (c:IsLocation(LOCATION_HAND) or c:GetFlagEffect(1)>0)
		and rc:IsRelateToEffect(re)
		and rc:IsLocation(LOCATION_MZONE)
		and seq~=5 and seq~=6
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local c=e:GetHandler()
	local seq=rc:GetSequence()
	--if re:GetHandlerPlayer()==1-tp then seq=4-seq end
	local zone=bit.lshift(1,seq)
	if chk==0 then return rc:IsReleasableByEffect()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,rc:GetControler())--,zone)
	end
	rc:CreateEffectRelation(e)
	e:SetLabel(zone)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,rc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,1-tp,0)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local sp=rc:GetControler()
	if rc:IsRelateToEffect(e) and Duel.Release(rc,REASON_EFFECT) and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,sp,false,false,POS_FACEUP_DEFENSE,e:GetLabel())
	end
end

