--Change Sentai - Change Robo
function c249001155.initial_effect(c)
	return
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,c249001155.matfilter,5,true,true)
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,aux.tdcfop(c))
	--copy spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(564)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c249001155.condition)
	e1:SetTarget(c249001155.target)
	e1:SetOperation(c249001155.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	c:RegisterEffect(e3)
	--spsummon condition
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetValue(c249001155.splimit)
	c:RegisterEffect(e4)
	--matcheck
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(c249001155.valcheck)
	e5:SetLabelObject(e1)
	c:RegisterEffect(e5)
end
function c249001155.matfilter(c)
	return c:IsFusionSetCard(0x10A5) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function c249001155.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1
end
function c249001155.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac
	local token
	repeat
		getmetatable(e:GetHandler()).announce_filter={0x20A5,OPCODE_ISSETCARD}
		ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
		token=Duel.CreateToken(tp,ac)
	until token:CheckActivateEffect(true,false,false)
	Duel.ConfirmCards(1-tp,Group.FromCards(token))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
function c249001155.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.CreateToken(tp,Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM))
	Duel.ConfirmCards(1-tp,Group.FromCards(tc))
	local tpe=tc:GetType()
	local te=tc:GetActivateEffect()
	local tg=te:GetTarget()
	local co=te:GetCost()
	local op=te:GetOperation()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(te)
	if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
	if tg then
		tg(te,tp,eg,ep,ev,re,r,rp,1)
	end
	Duel.BreakEffect()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g then
		local etc=g:GetFirst()
		while etc do
			etc:CreateEffectRelation(te)
			etc=g:GetNext()
		end
	end
	if op then
		op(te,tp,eg,ep,ev,re,r,rp)
	end
	tc:ReleaseEffectRelation(te)
	if g then
		etc=g:GetFirst()
		while etc do
			etc:ReleaseEffectRelation(te)
			etc=g:GetNext()
		end
	end
end
function c249001155.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function c249001155.valcheck(e,c)
	local g=c:GetMaterial():Filter(Card.IsSetCard,nil,0x10A5)
	if g:GetClassCount(Card.GetCode)==5 then e:GetLabelObject():SetLabel(1) end
end