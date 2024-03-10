--created by Walrus, coded by XGlitchy30
--Voidictator Deity - Omen the Dark Angel
local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+100
	end
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.matfilter,3,true)
	c:SetUniqueOnField(1,0,id)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.FusionSummonedCond)
	e1:SetTarget(s.lztg)
	e1:SetOperation(s.lzop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EVENT_REMOVE)
	e2x:SetCondition(s.thcon2)
	c:RegisterEffect(e2x)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_SPSUMMON_SUCCESS,s.cfilter,s.progressive_id,LOCATION_MZONE,nil,LOCATION_MZONE,nil,nil,true)
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CUSTOM+s.progressive_id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(3)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
end
function s.matfilter(c,fc,sub,mg,sg)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:IsExists(Card.IsFusionSetCard,1,nil,ARCHE_VOIDICTATOR))
end
function s.lztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)+Duel.GetLocationCount(1-tp,LOCATION_SZONE,PLAYER_NONE,0)>0 end
	local dis=Duel.SelectDisableField(tp,2,0,LOCATION_ONFIELD,0xe000e0)
	Duel.SetTargetParam(dis)
	Duel.Hint(HINT_ZONE,tp,dis)
end
function s.lzop(e,tp,eg,ep,ev,re,r,rp)
	local zone=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tp==1 then
		zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
	end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetValue(zone)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and not c:IsLocation(LOCATION_DECK)
end
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_VOIDICTATOR_SERVANT) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c,nil,LOCATION_EXTRA)>0 then
		local g=Duel.Group(s.thfilter,tp,LOCATION_DECK,0,nil)
		if #g>=2 and Duel.SelectYesNo(tp,STRING_ASK_SEARCH) then
			Duel.HintMessage(tp,HINTMSG_ATOHAND)
			local tg=g:Select(tp,2,2,nil)
			if #tg>0 then
				Duel.BreakEffect()
				Duel.Search(tg,tp)
			end
		end
	end
end
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSummonPlayer(1-tp)
end
function s.checkfilter(c)
	return c:IsFaceup() and not c:IsForbidden()
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards():Filter(s.checkfilter,nil)
	if not c:IsRelateToChain() or c:IsFacedown() or #g<=0 then return end
	local tc=g:GetFirst()
	if #g>1 then
		Duel.HintMessage(tp,HINTMSG_SELECT)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		tc=sg:GetFirst()
	else
		Duel.HintSelection(Group.FromCards(tc))
	end
	if tc then
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,2)
	end
end
