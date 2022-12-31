--Fiorceleste, l'Arma Segreta di Elyria
--Script by XGlitchy30
function c38648112.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xe841),2,2)
	--atk boost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c38648112.atktg)
	e1:SetValue(c38648112.atkval)
	c:RegisterEffect(e1)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_FIELD)
	e2x:SetCode(EFFECT_PIERCE)
	e2x:SetRange(LOCATION_MZONE)
	e2x:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2x:SetTarget(c38648112.etg)
	e2x:SetValue(1)
	c:RegisterEffect(e2x)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38648112,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCondition(c38648112.spcon)
	e3:SetTarget(c38648112.sptg)
	e3:SetOperation(c38648112.spop)
	c:RegisterEffect(e3)
end
--filters
function c38648112.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsType(TYPE_MONSTER)
end
function c38648112.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ((c:IsFaceup() and c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp)>0) or c:IsLocation(LOCATION_GRAVE))
end
--atk boost
function c38648112.atktg(e,c)
	return c:IsSetCard(0xe841) and c:IsFaceup()
end
function c38648112.atkval(e,c)
	return Duel.GetMatchingGroupCount(c38648112.atkfilter,c:GetControler(),LOCATION_EXTRA+LOCATION_GRAVE,0,nil)*100
end
--pierce
function c38648112.etg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
--spsummon
function c38648112.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_BATTLE)
end
function c38648112.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c38648112.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
function c38648112.spop(e,tp,eg,ep,ev,re,r,rp)
	local extra=0
	local g=nil
	local g2=nil
	if Duel.GetLocationCountFromEx(tp)>1 then
		extra=2
	elseif Duel.GetLocationCountFromEx(tp)==1 then
		extra=1
	else
		extra=0
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if extra==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38648112.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,ft,nil,e,tp)
	elseif extra==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38648112.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
		if ft>1 then
			if g:GetFirst():IsLocation(LOCATION_EXTRA) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38648112.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38648112.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
			end
		end
		if g2~=nil then
			g:Merge(g2)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38648112.spfilter),tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	end
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end