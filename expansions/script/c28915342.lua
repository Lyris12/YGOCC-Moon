--Great Divexplorer, Wite
local ref,id=GetID()
function ref.initial_effect(c)
	--Recover
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(ref.sscost)
	e1:SetTarget(ref.sstg)
	e1:SetOperation(ref.ssop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--Summon
	local ck1=Effect.CreateEffect(c)
	ck1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ck1:SetCode(EVENT_CHAINING)
	ck1:SetRange(LOCATION_HAND+LOCATION_REMOVED)
	ck1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	ck1:SetLabel(-1)
	ck1:SetOperation(ref.chainreg)
	c:RegisterEffect(ck1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND+LOCATION_REMOVED)
	e2:SetCountLimit(1,id+1000)
	e2:SetLabelObject(ck1)
	e2:SetCondition(ref.spcon)
	e2:SetTarget(ref.sptg)
	e2:SetOperation(ref.spop)
	c:RegisterEffect(e2)
end

--Special Summon
function ref.sscfilter(c)
	return c:IsSetCard(0x72e) and c:IsAbleToRemoveAsCost()
end
function ref.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(ref.sscfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,ref.sscfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsAbleToHand() --c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT) --Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Summon
function ref.checkPZone(c,e,tp)
	if (Duel.GetFieldCard(tp,LOCATION_PZONE,0)==rc) or (Duel.GetFieldCard(1-tp,LOCATION_PZONE,0)==rc) then return 0
	else return 4
	end
end
function ref.chainreg(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_PENDULUM) then
		e:SetLabel(re:GetHandler():GetSequence())--ref.checkPZone(rc,e,tp))
	end
	aux.chainreg(e,tp,eg,ep,ev,re,r,rp)
end
function ref.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and (e:GetHandler():GetFlagEffect(1)>0 or e:GetHandler():IsLocation(LOCATION_HAND))
end
function ref.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local seq=re:GetActivateSequence()
	--Debug.Message("Sequence: " .. seq)
	--Debug.Message("Handler: " .. re:GetHandler():GetSequence())
	if re:IsActiveType(TYPE_PENDULUM) then
		seq=e:GetLabelObject():GetLabel()
		if seq==-1 then 
			seq=re:GetHandler():GetSequence()--ref.checkPZone(re:GetHandler(),e,tp)
		end
	end
	if re:GetHandlerPlayer()==1-tp then seq=4-seq end
	local zone=bit.lshift(1,seq)
	--Debug.Message("Zone: " .. zone .. "; Bitshifted: " .. bit.lshift(1,zone))
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
	end
	e:SetLabel(zone)
	e:GetLabelObject():SetLabel(-1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function ref.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
		--Debug.Message("Target Zone: " .. zone)
		--Debug.Message("Zone: " .. c:GetSequence() .. "; Column: " .. aux.GetColumn(c,tp))
	end
end

--Foolish
function ref.grfilter(c)
	return c:IsSetCard(0x72e) and c:IsAbleToGrave()
end
function ref.grtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.grfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,0)
end
function ref.grop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,ref.grfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
