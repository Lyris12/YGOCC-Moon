--Alphacenta Markshall
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:GLString(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop0)
	c:RegisterEffect(e1)
	--special summon proc
	local e2=Effect.CreateEffect(c)
	e2:GLString(1)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(cid.spcon)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	--pop and place
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetLabel(101)
	e3:SetCondition(cid.sscon)
	e3:SetTarget(cid.sstg)
	e3:SetOperation(cid.ssop)
	c:RegisterEffect(e3)
end
function cid.counterfilter(c)
	return c:IsSetCard(0x7a4) or c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM)
end
--SPSUMMON
function cid.spfilter(c,e,tp,atk)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PANDEMONIUM) and c:GetAttack()>atk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and ((not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0) 
end
function cid.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PENDULUM) and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttack())
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsType(TYPE_PENDULUM) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA)
end
function cid.spop0(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not e:GetHandler():IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local atk=tc:GetAttack()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp,atk):GetFirst()
	if sc then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--SPECIAL SUMMON PROC
function cid.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
function cid.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(cid.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.splimit)
	Duel.RegisterEffect(e1,tp)
end
function cid.splimit(e,c)
	return not cid.counterfilter(c)
end

--POP AND PLACE
function cid.sscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		and (Duel.GetCurrentChain()==0 or Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_PLAYER)~=1-tp)
end
function cid.dryfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PENDULUM|TYPE_PANDEMONIUM) and c:IsSetCard(0x7a4)
		and Duel.IsExistingMatchingCard(cid.pfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetOriginalAttribute(),c:GetType())
end
function cid.pfilter(c,e,tp,attr,typ)
	local ptyp=c:GetType()&(TYPE_PENDULUM|TYPE_PANDEMONIUM)
	if not (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x7a4) and c:IsAttribute(attr) and not c:IsForbidden() and typ&ptyp==0) then return false end
	if ptyp&TYPE_PENDULUM>0 then
		if (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and c:IsCanPlaceOnField(tp,tp,LOCATION_PZONE,e,REASON_EFFECT) then
			return true
		end
	end
	if ptyp&TYPE_PANDEMONIUM>0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsCanPlaceOnField(tp,tp,LOCATION_PANDEZONE,e,REASON_EFFECT) then
			return true
		end
	end
	return false
end
function cid.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.dryfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
function cid.ssop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,cid.dryfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	if g1:GetCount()>0 then
		Duel.HintSelection(g1)
		if Duel.Destroy(g1,REASON_EFFECT)~=0 then
			local attr,typ=g1:GetFirst():GetOriginalAttribute(),g1:GetFirst():GetType()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
			local g2=Duel.SelectMatchingCard(tp,cid.pfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,attr,typ):GetFirst()
			if not g2 then return end
			if g2:IsType(TYPE_PENDULUM) then
				Duel.MoveToField(g2,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			else
				aux.PandAct(g2)(e,tp,eg,ep,ev,re,r,rp)
			end		
		end
	end
end