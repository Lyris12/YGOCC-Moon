--Stellarius Sanctuary
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Unaffected by trap effects, continuous effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.immcon)
	e1:SetValue(s.unval)
	c:RegisterEffect(e1)
	--if card is banished/activate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.actcon)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
	--Xyz
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCountLimit(1,id+1)
	e3:SetRange(LOCATION_FZONE)
--	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_series={0x12D9}

function s.unval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.imfilter(c,e,tp)
	return c:IsSetCard(0x12D9) and c:IsType(TYPE_FUSION)
end
function s.immcon(c,e,tp)
	return Duel.IsExistingMatchingCard(s.imfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsSetCard(0x12D9) and c:IsType(TYPE_CONTINUOUS)
	and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.cfilter,1,nil,tp) then
		local tc=eg:GetFirst()
		e:SetLabel(tc:GetCode())
		return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,tp,tc:GetCode())
	end
end
--
function s.actfilter2(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.actfilter(c,tp,cd)
	return c:IsSetCard(0x12D9) and c:IsType(TYPE_CONTINUOUS) and c:GetActivateEffect():IsActivatable(tp,true)
		and not Duel.IsExistingMatchingCard(s.actfilter2,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode()) and not c:IsCode(cd)
end



	
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)	
	local cd=eg:GetFirst():GetCode()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,tp,e:GetLabel())
	end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then  
	local sg=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp,e:GetLabel())
	local tc=sg:GetFirst()
	if tc then
	Duel.HintSelection(sg)
	local tpe=tc:GetType()
	local te=tc:GetActivateEffect()
	local tg=te:GetTarget()
	local co=te:GetCost()
	local op=te:GetOperation()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	Duel.ClearTargetCard()
	if bit.band(tpe,TYPE_FIELD)~=0 and not tc:IsType(TYPE_FIELD) and not tc:IsFacedown() then
		local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		if Duel.IsDuelType(DUEL_OBSOLETE_RULING) then
			if fc then Duel.Destroy(fc,REASON_RULE) end
			fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
		else
			fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
		end
	end
	Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	if tc and tc:IsFacedown() then Duel.ChangePosition(tc,POS_FACEUP) end
	Duel.Hint(HINT_CARD,0,tc:GetCode())
	tc:CreateEffectRelation(te)
	if bit.band(tpe,TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
		tc:CancelToGrave(false) 	
	end
	if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
	if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
	Duel.BreakEffect()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g then
		local etc=g:GetFirst()
		while etc do
			etc:CreateEffectRelation(te)
			etc=g:GetNext()
		end
	end
	if op then op(te,tp,eg,ep,ev,re,r,rp) end
	tc:ReleaseEffectRelation(te)
	if etc then	
		etc=g:GetFirst()
		while etc do
			etc:ReleaseEffectRelation(te)
			etc=g:GetNext()
			end
		end
	end
end
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.costfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToGrave() and c:IsSetCard(0x12D9) and c:IsType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) 
end
function s.costfilter2(c,tp)
	return c:IsFaceup() and c:IsAbleToGrave() and c:IsSetCard(0x12D9) and c:IsType(TYPE_SPELL+TYPE_TRAP) 
end
function s.costfilter3(c,tp)
	return c:IsFaceup() and c:IsAbleToGrave() and c:IsSetCard(0x12D9) and c:IsType(TYPE_MONSTER) and c:IsCanBeXyzMaterial(c,tp) and c:IsLevel(4)
end
function s.costfilter4(c,tp)
	return c:IsSetCard(0x12D9) and c:IsType(TYPE_MONSTER) and c:IsLevel(4)
end
function s.tfilter(c,tp)
	return (c:IsSetCard(0x12D9) and c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(0x12D9))
	and c:IsCanBeXyzMaterial(c,tp) and c:IsLevel(4)
end
function s.mfilter1(c,mg,tp)
	return mg:IsExists(s.mfilter2,1,c,c,tp)
end
function s.mfilter2(c,c1,tp)
	return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,Group.FromCards(c,c1))
end
function s.xyzfilter(c,mg)
	return c:IsXyzSummonable(mg,2,2) and c:IsSetCard(0x12D9)
end
function s.costfilter5(c,tp)
	return c:IsFaceup() and c:IsAbleToGrave() and c:IsSetCard(0x12D9) and c:IsType(TYPE_MONSTER) and c:IsLevel(4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.tfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil)
	local gs2=Duel.GetMatchingGroup(s.costfilter2,tp,LOCATION_SZONE,0,e:GetHandler())
	local gs3=Duel.GetMatchingGroup(s.costfilter3,tp,LOCATION_MZONE,0,e:GetHandler())
	local gs4=Duel.GetMatchingGroup(s.costfilter4,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #mg>1
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,mg) and #mg>=2 and not (#gs3>=2 and #gs4==0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local gs=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	local gs2=Duel.GetMatchingGroup(s.costfilter2,tp,LOCATION_SZONE,0,e:GetHandler())
	local gs3=Duel.GetMatchingGroup(s.costfilter3,tp,LOCATION_MZONE,0,e:GetHandler())
	local gs4=Duel.GetMatchingGroup(s.costfilter4,tp,LOCATION_GRAVE,0,nil)
	local mg=Duel.GetMatchingGroup(s.tfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=-2 then return end
	if #mg<=1 or (#gs3>=2 and #gs4==0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	if (#gs3>=1 and #gs2==0 and #gs4==1) then
	local gs=Duel.SelectMatchingCard(tp,s.costfilter5,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SendtoGrave(gs,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.BreakEffect()
	local mg1=mg:FilterSelect(tp,s.mfilter2,1,1,nil,mg,tp)
	local mc=mg1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mg2=mg:FilterSelect(tp,s.mfilter2,1,1,mc,mc,tp)
	mg1:Merge(mg2)
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg1)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,mg1,2,2)
	end
	else
	local gs=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SendtoGrave(gs,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.BreakEffect()
	local mg1=mg:FilterSelect(tp,s.mfilter2,1,1,nil,mg,tp)
	local mc=mg1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mg2=mg:FilterSelect(tp,s.mfilter2,1,1,mc,mc,tp)
	mg1:Merge(mg2)
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg1)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,mg1,2,2)
end
end
end


