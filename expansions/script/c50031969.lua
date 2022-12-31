--The Fabled Ganashrimro
function c50031969.initial_effect(c)
		--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST),2,2,c50031969.lcheck)
--disable spsummon
   local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	 e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,50031969)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(c50031969.thtg)
	e2:SetOperation(c50031969.thop)
	c:RegisterEffect(e2)
		  --atkup
  --special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50031969,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	 e4:SetCountLimit(1,50031769)
	e4:SetTarget(c50031969.sptg)
	e4:SetCost(c50031969.cost)
	e4:SetOperation(c50031969.spop)
	c:RegisterEffect(e4)
Duel.AddCustomActivityCounter(50031969,ACTIVITY_SPSUMMON,c50031969.counterfilter)
end

function c50031969.lcheck(g,lc)
	return g:IsExists(Card.IsSetCard,1,nil,0x35)
end
function c50031969.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA or (c:IsSetCard(0x35) or c:IsRace(RACE_BEAST))
end
function c50031969.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(50031969,tp,ACTIVITY_SPSUMMON)==0 and Duel.CheckLPCost(tp,1500)  end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c50031969.splimit)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
	Duel.RegisterEffect(e1,tp)
	Duel.PayLPCost(tp,1500)
end
function c50031969.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsSetCard(0x35) or c:IsRace(RACE_BEAST))
end
function c50031969.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c50031969.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50031969.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c50031969.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ft=2
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	ft=math.min(ft,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c50031969.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end

function c50031969.spop(e,tp,eg,ep,ev,re,r,rp)
   local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=g:Select(tp,ft,ft,nil)
	end
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
 Duel.ShuffleHand(tp)
 Duel.BreakEffect()
				 Duel.DiscardHand(tp,nil,2,2,REASON_EFFECT+REASON_DISCARD)

	end
end
function c50031969.atkfilter(c)
	return c:IsFaceup()  and c:IsType(TYPE_PENDULUM)  
end


function c50031969.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc:IsPreviousLocation(LOCATION_HAND) and tc:IsLevelBelow(4) and (tc:IsSetCard(0x35) or tc:IsRace(RACE_BEAST)) and bit.band(r,REASON_DISCARD)~=0  end
	tc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
end
function c50031969.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
   if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e)  then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end