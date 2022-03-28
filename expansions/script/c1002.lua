--Ergoriesumato Jetcodice - Origine
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_ANONYMIZE)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	--amnesia
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+200)
	e2:SetCondition(s.namecon)
	e2:SetCost(s.namecost)
	e2:SetTarget(s.nametg)
	e2:SetOperation(s.nameop)
	c:RegisterEffect(e2)
	--set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCountLimit(1,id+100)
	e3:SetTarget(s.sstg)
	e3:SetOperation(s.ssop)
	c:RegisterEffect(e3)
	local e3x=e3:Clone()
	e3x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3x)
end
function s.counterfilter(c)
	local code=c:GetOriginalCode()
	return code<10000 or c:IsOriginalCodeRule(CARD_ANONYMIZE)
end
function s.chainfilter(re,tp,cid)
	local code=re:GetHandler():GetOriginalCode()
	return code<10000 or re:GetHandler():IsOriginalCodeRule(CARD_ANONYMIZE)
end

function s.sprfilter(c)
	return c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD) and (c:IsFaceup() or not c:IsOnField()) and c:IsAbleToDeckOrExtraAsCost() or c:IsLocation(LOCATION_EXTRA) and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
function s.namecount(g,cc)
	if cc==nil then return true end
	local count=0
	local sg=g:Clone()
	sg:RemoveCard(cc)
	for c in aux.Next(sg) do
		local code,code2=c:GetCode()
		if code2 then
			count=count+2
		else
			count=count+1
		end
		if count>=2 then
			sg:DeleteGroup()
			return false
		end
	end
	sg:DeleteGroup()
	return true
end
function s.fselect(g,tp)
	local count=0
	for c in aux.Next(g) do
		local code,code2=c:GetCode()
		if code2 then
			count=count+2
		else
			count=count+1
		end
		if count>=2 then
			break
		end
	end
	return Duel.GetMZoneCount(tp,g)>0 and g:GetClassCount(Card.GetCode)==#g and count>=2
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA,0,c)
	aux.GCheckAdditional=s.namecount
	local res=rg:CheckSubGroup(s.fselect,1,#rg,tp)
	aux.GCheckAdditional=nil
	return res
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA,0,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	aux.GCheckAdditional=s.namecount
	local sg=rg:SelectSubGroup(tp,s.fselect,true,1,#rg,tp)
	aux.GCheckAdditional=nil
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	local sg=g:Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_ONFIELD)
	local rg=g:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
	Duel.ConfirmCards(1-tp,g)
	if #sg>0 then
		Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_COST)
	end
	if #rg>0 then
		Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
	end
	g:DeleteGroup()
	if c:IsLocation(LOCATION_GRAVE) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end

function s.namecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)<=0
end
function s.namecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:IsHasType(EFFECT_TYPE_ACTIONS) and e:GetHandler():IsCode(id) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,2)
	end
end
function s.filter(c,e,tp)
	if not c:IsFaceup() then return false end
	if c:IsCode(CARD_ANONYMIZE) and c:IsAbleToDeck() then
		return true
	end
	return (#{c:GetCode()}>1 or not c:IsCode(CARD_ANONYMIZE)) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spf,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetOriginalCode())
end
function s.spf(c,e,tp,code)
	return c:IsType(TYPE_MONSTER) and c:GetOriginalCode()<code and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.nametg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		local code,code2=tc:GetCode()
		if not code2 then
			if code==CARD_ANONYMIZE then
				Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tc:GetControler(),tc:GetLocation())
			else
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
			end
		end
	end
end
function s.nameop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local desc,opt={},{}
	local b1=(tc:IsCode(CARD_ANONYMIZE) and tc:IsAbleToDeck()) 
	local b2=((#{tc:GetCode()}>1 or not tc:IsCode(CARD_ANONYMIZE)) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spf,tp,LOCATION_DECK,0,1,nil,e,tp,tc:GetOriginalCode()))
	if not b1 and not b2 then return end
	if b1 then
		table.insert(desc,aux.Stringid(id,4))
		table.insert(opt,0)
	end
	if b2 then
		table.insert(desc,aux.Stringid(id,3))
		table.insert(opt,1)
	end
	local op=opt[Duel.SelectOption(tp,table.unpack(desc))+1]
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spf,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetOriginalCode()):GetFirst()
		if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) then
			--local negate
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e2)
			--global negate
			local g1=Effect.CreateEffect(e:GetHandler())
			g1:SetType(EFFECT_TYPE_FIELD)
			g1:SetCode(EFFECT_DISABLE)
			g1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			g1:SetTarget(s.distg)
			g1:SetLabel(tc:GetOriginalCode())
			g1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(g1,tp)
			local g2=Effect.CreateEffect(e:GetHandler())
			g2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			g2:SetCode(EVENT_CHAIN_SOLVING)
			g2:SetCondition(s.discon)
			g2:SetOperation(s.disop)
			g2:SetLabel(tc:GetOriginalCode())
			g2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(g2,tp)
		end
	else
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
function s.distg(e,c)
	local cd=e:GetLabel()
	return (not c:IsType(TYPE_MONSTER) or (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)) and c:IsControler(e:GetHandlerPlayer()) and c:GetOriginalCode()>cd
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local cd=e:GetLabel()
	return re:GetHandler():GetOriginalCode()>cd and re:GetHandler():IsControler(e:GetHandlerPlayer())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

function s.ssfilter(c)
	return c:IsCode(CARD_ANONYMIZE) and not c:IsType(TYPE_FIELD) and c:IsSSetable()
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SSet(tp,tc)~=0 then
		if tc:IsType(TYPE_QUICKPLAY) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		elseif tc:IsType(TYPE_TRAP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
