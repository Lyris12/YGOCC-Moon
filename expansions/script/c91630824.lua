--Lich-Lord Baz'ri
local cid,id=GetID()
function cid.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(cid.spcon)
	e1:SetCost(cid.spcost)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	--Pos Change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_POSITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(cid.target)
	e2:SetCondition(cid.ccon)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e2)
	--swap ad
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(cid.target)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(cid.ccon)
	e3:SetCode(EFFECT_SWAP_AD)
	c:RegisterEffect(e3)
	--Once per turn, during your Standby Phase, if there is no "Lich-Lord's Phylactery" in your GY: Destroy this card, and if you do, add 1 Level 5 or lower Zombie monster from your Deck or GY to your hand.
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e5:SetCondition(function(e) return not cid.ccon(e) and Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
	e5:SetTarget(cid.destg)
	e5:SetOperation(cid.desop)
	c:RegisterEffect(e5)
end
function cid.thfilter(c)
	return c:IsLevelBelow(5) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	if Duel.GetTurnPlayer()==tp then
		return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
	else
		return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
	end
end
function cid.rfilter(c,tp)
	if not c:IsRace(RACE_ZOMBIE) then return false end
	return not tp or (c:IsControler(tp) and Duel.CheckReleaseGroup(tp,cid.rfilter,1,c,false))
end

function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ge=Effect.CreateEffect(e:GetHandler())
		ge:SetDescription(aux.Stringid(9163835,11))
		ge:SetType(EFFECT_TYPE_FIELD)
		ge:SetCode(EFFECT_EXTRA_RELEASE_NONSUM)
		ge:SetTargetRange(0,LOCATION_MZONE)
		ge:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
		ge:SetLabelObject(e)
		ge:SetValue(cid.relval)
		ge:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(ge,tp)
		local check=Duel.CheckReleaseGroup(tp,cid.rfilter,1,nil,tp)
		if check then
			ge:Reset()
			return true
		else
			ge:Reset()
			return false
		end
	end
	local ge=Effect.CreateEffect(e:GetHandler())
	ge:SetDescription(aux.Stringid(9163835,11))
	ge:SetType(EFFECT_TYPE_FIELD)
	ge:SetCode(EFFECT_EXTRA_RELEASE_NONSUM)
	ge:SetTargetRange(0,LOCATION_MZONE)
	ge:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	ge:SetLabelObject(e)
	ge:SetValue(cid.relval)
	ge:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(ge,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroup(tp,cid.rfilter,1,1,nil,tp)
	if #g<=0 then ge:Reset() return end
	local g2=Duel.SelectReleaseGroup(tp,cid.rfilter,1,1,g,false)
	if #g2<=0 then ge:Reset() return end
	g:Merge(g2)
	Duel.Release(g,REASON_COST)
	ge:Reset()
end
function cid.relval(e,re,r,rp)
	return re:IsActivated() and bit.band(r,REASON_COST)~=0 and re==e:GetLabelObject()
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFlagEffect(tp,id)==0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
function cid.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(id)==e:GetLabel()
end
function cid.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_CARD,0,id)
	Duel.SendtoDeck(tc,nil,1,REASON_EFFECT)
end
function cid.cfilter1(c)
	return c:IsCode(91630827)
end
function cid.ccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.cfilter1,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil)
end
function cid.target(e,c)
	return c:IsSetCard(0x2e7) and c:IsFaceup()
end
