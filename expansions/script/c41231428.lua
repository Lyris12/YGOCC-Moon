--created by Jake, coded by XGlitchy30
--Dawn Blader - King of Heroes
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_DISCARD)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(s.cond1)
	e2:SetTarget(s.tg1)
	e2:SetOperation(s.op1)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:Desc(2)
	e2x:SetCode(EVENT_CHAINING)
	e2x:SetCondition(s.chcon)
	c:RegisterEffect(e2x)
	local e2y=e2:Clone()
	e2y:Desc(3)
	e2y:SetCategory(CATEGORY_HANDES)
	e2y:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2y:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2y:SetCondition(s.hdcon)
	e2y:SetTarget(aux.DiscardTarget())
	e2y:SetOperation(aux.DiscardOperation())
	c:RegisterEffect(e2y)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DDD)
	e3:SetCode(EVENT_DISCARD)
	e3:HOPT()
	e3:SetCondition(s.dsccond)
	e3:SetTarget(aux.SearchTarget(s.thfil))
	e3:SetOperation(aux.SearchOperation(s.thfil))
	c:RegisterEffect(e3)
	if not s.global_check then
		global_check=true
		s[0]=nil
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DISCARD)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetCurrentChain()
	if cid>0 and eg:IsExists(s.filter,1,nil,true) then
		s[0]=Duel.GetChainInfo(cid,CHAININFO_CHAIN_ID)
	end
end
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(0x613) and c:IsDiscardable()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	Duel.DiscardHand(tp,s.cfilter,2,2,REASON_COST+REASON_DISCARD,e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.filter(c,chain)
	return c:IsMonster() and c:IsSetCard(0x613) and (not chain or c:IsReason(REASON_COST))
end
function s.cond1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil)
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActivated() and Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==s[0]
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x613) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummonNegate(e,g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.Faceup(s.filter),1,nil)
end
function s.thfil(c)
	return c:IsMonster() and c:IsSetCard(0x613)
end
function s.dsccond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x613) and (c:IsReason(REASON_EFFECT) or (c:IsReason(REASON_COST) and re:IsActivated()))
end
