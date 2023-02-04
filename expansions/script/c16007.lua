--Paracyclis Hercules, Stagpunisher

local s,id=GetID()
function s.initial_effect(c)
	--spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(s.dircon)
	c:RegisterEffect(e2)
	--Special Summon
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DDD)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	e3:SetCountLimit(1,id)
	c:RegisterEffect(e3)
end
function s.sppfilter(c)
	return c:IsReleasable() and c:IsPosition(POS_FACEDOWN_DEFENSE)
end
function s.spcheck(g,tp)
	return Duel.GetMZoneCount(tp,g)>0 and Duel.CheckReleaseGroup(tp,s.spchkfil,1,nil,g,tp)
end
function s.spchkfil(c,g,tp)
	return g:IsContains(c) and c:IsControler(tp)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g1=Duel.GetReleaseGroup(tp):Filter(Card.IsSetCard,c,0x308)
	local g2=Duel.GetMatchingGroup(s.sppfilter,tp,0,LOCATION_MZONE,1,nil)
	g1:Merge(g2)
	return g1:CheckSubGroup(s.spcheck,2,2,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g1=Duel.GetReleaseGroup(tp):Filter(Card.IsSetCard,c,0x308)
	local g2=Duel.GetMatchingGroup(s.sppfilter,tp,0,LOCATION_MZONE,1,nil)
	g1:Merge(g2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=g1:SelectSubGroup(tp,s.spcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end

function s.dircon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and not Duel.IsExistingMatchingCard(aux.NOT(Card.IsPosition),tp,0,LOCATION_MZONE,1,nil,POS_FACEDOWN_DEFENSE)
end

function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,c:GetOwner()) and Duel.GetLocationCount(c:GetOwner(),LOCATION_MZONE,tp)>0
end
function s.gcheck(g)
	return g:GetClassCount(Card.GetControler)>1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.IsExistingTarget(s.filter,1-tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,PLAYER_ALL,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	local count=0
	for tc in aux.Next(g) do
		if Duel.GetLocationCount(tc:GetOwner(),LOCATION_MZONE,tp)>0 then
			local ct=Duel.SpecialSummon(tc,0,tp,tc:GetOwner(),false,false,POS_FACEDOWN_DEFENSE)
			count=count+ct
		end
	end
	if count>0 and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		local tg=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_MZONE,1,1,nil)
		if #tg>0 then
			Duel.HintSelection(tg)
			local tc=tg:GetFirst()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:Desc(2)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCondition(s.limcon)
			if Duel.GetTurnPlayer()==tp then
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
			else
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
			end
			e1:SetLabel(Duel.GetTurnCount(),tp)
			tc:RegisterEffect(e1)
		end
	end
end
function s.limcon(e)
	local ct,tp=e:GetLabel()
	return Duel.GetTurnCount()>ct and Duel.GetTurnPlayer()==1-tp
end