--Ignitronix Ulticorex
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.mfilter,1,1)
	--If an "Ignitronix" monster you control would be destroyed by battle or card effect, you can destroy another "Ignitronix" Monster Card you control instead.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetTarget(s.reptg)
	e1:SetOperation(s.repop)
	e1:SetValue(s.repval)
	c:RegisterEffect(e1)
	--If this card is Link Summoned: You can send 1 "Ignitronix" card from your Deck to the GY.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--(Quick Effect): You can decrease the Energy of your Engaged "Ignitronix Engine" by up to 6; for the rest of this turn, all "Ignitronix" monsters you control will gain 100 ATK/DEF x the Energy reduced to activate this effect
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(s.adcost)
	e3:SetTarget(s.adtg)
	e3:SetOperation(s.adop)
	c:RegisterEffect(e3)
end
function s.mfilter(c)
	return not c:IsLinkType(TYPE_LINK) and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x725)
end
function s.filter1(c,tp)
	return not c:IsReason(REASON_REPLACE) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsFaceup() and c:IsSetCard(0x725) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.filter2(c,e)
	return c:IsSetCard(0x725) and c:IsFaceup() and c:IsDestructable(e) and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.filter1,nil,tp)
	local tg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return #g>0 and #tg>0 end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local xg=tg:Select(tp,1,1,nil)
		Duel.SetTargetCard(xg)
		xg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function s.repval(e,c)
	return s.filter1(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local tc=Duel.GetFirstTarget()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.tgfilter(c)
	return c:IsSetCard(0x725) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
    if chk==0 then return en and en:IsMonster(TYPE_DRIVE) and en:IsCode(77222587) and (
		en:IsCanUpdateEnergy(-1,tp,REASON_COST) or
		en:IsCanUpdateEnergy(-2,tp,REASON_COST) or
		en:IsCanUpdateEnergy(-3,tp,REASON_COST) or
		en:IsCanUpdateEnergy(-4,tp,REASON_COST) or
		en:IsCanUpdateEnergy(-5,tp,REASON_COST) or
		en:IsCanUpdateEnergy(-6,tp,REASON_COST)
	)	end
	
	local t={}
    for _,i in ipairs{-6,-5,-4,-3,-2,-1} do if en:IsCanUpdateEnergy(i,tp,REASON_EFFECT) then table.insert(t,i) end end
	ene=Duel.AnnounceNumber(tp,table.unpack(t))
    en:UpdateEnergy(ene,tp,REASON_COST,true,e:GetHandler())
	e:SetLabel(ene)
end
function s.adfilter(e,c)
    return c:IsSetCard(0x725)
end
function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	local ene=e:GetLabel()
    local val=100*-ene
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.adfilter)
	e1:SetValue(val)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	Duel.RegisterEffect(e2,tp)
end