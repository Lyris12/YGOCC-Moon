--Paracyclis Hercules, Stagpunisher
--Automate ID
local s,id=GetID()
function s.initial_effect(c)
	--spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.dircon)
	e1:SetCountLimit(1,id+100)
	c:RegisterEffect(e1)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetCountLimit(1,id+200)
	c:RegisterEffect(e1)
end
function s.sptfilter(c,tp)
	return c:IsReleasable() and Duel.GetMZoneCount(tp,c,tp)>0 and c:IsSetCard(0x308)
end
function s.sppfilter(c,tp)
	return c:IsReleasable() and Duel.GetMZoneCount(1-tp,c,tp)>0
	and c:IsPosition(POS_FACEDOWN_DEFENSE)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.sptfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	and Duel.IsExistingMatchingCard(s.sppfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.sptfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	g:AddCard(Duel.SelectMatchingCard(tp,s.sppfilter,tp,0,LOCATION_MZONE,1,1,nil,tp):GetFirst())
	Duel.Release(g,REASON_COST)
end
function s.dircon(e)
	local tp=e:GetHandler():GetControler()
	return not Duel.IsExistingMatchingCard(function(c)
		return c:IsAttackPos() or c:IsFaceup()
	end,tp,0,LOCATION_MZONE,1,nil)
end
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(s.filter,1-tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
	local og=Duel.SelectTarget(tp,s.filter,1-tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local sc=sg:GetFirst()
	local oc=og:GetFirst()
	local g=Group.FromCards(sc,oc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,PLAYER_ALL,g:GetFirst():GetOwner())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g1=g:GetFirst()
	local g2=g:GetNext()
	if g1:GetControler()==1-tp then g1,g2=g2,g1 end
	if (Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE) +
		Duel.SpecialSummon(g2,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)) >0 then
		local tg=Duel.SelectTarget(tp,Card.IsFacedown,1-tp,LOCATION_MZONE,0,1,1,nil)
		if not tg then return end
		local tc=tg:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(function(e,tp) return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()==tp end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end
