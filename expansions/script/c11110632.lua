--Lifeweaver's Light
--Luce della Vitatessitrice
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--[[Monsters your opponent controls lose 300 ATK for each of your banished "Lifeweaver" monsters with different names.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--[[If a "Lifeweaver" Time Leap Monster(s) returns from your field to your Extra Deck (except during the Damage Step):
	You can Special Summon from your Extra Deck, 1 "Lifeweaver" Time Leap Monster with the same Future that 1 of those monsters had on the field,
	but with a different Attribute than that monster had on the field.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_TO_DECK,s.condfilter,id)
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_SZONE)
	e3:HOPT()
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
--FILTERS E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(ARCHE_LIFEWEAVER)
end
--E2
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.Group(s.cfilter,tp,LOCATION_REMOVED,0,nil)
	if not g or #g<=0 then return 0 end
	return g:GetClassCount(Card.GetCode)*-300
end

--FILTERS E3
function s.condfilter(c,_,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp) and c:IsLocation(LOCATION_EXTRA) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsType(TYPE_TIMELEAP) and c:IsPreviousTypeOnField(TYPE_TIMELEAP)
		and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsPreviousSetCard(ARCHE_LIFEWEAVER)
end
function s.chkfilter(c,tp,fut,attr,nocheck,resolution)
	if type(resolution)~="number" and not s.condfilter(c,nil,tp) then return false end
	if nocheck then return true end
	local f1,f2
	if type(resolution)=="number" then
		local eset={c:IsHasEffect(id)}
		for _,e in ipairs(eset) do
			local eid,stored_fut,stored_attr=e:GetLabel()
			if eid==resolution then
				f1,f2 = stored_fut,stored_attr
			end
		end
		if not f1 or not f2 then return false end
	else
		f1,f2 = c:GetPreviousFutureOnField(),c:GetPreviousAttributeOnField()
	end
	return f1==fut and f2~=attr
end
function s.spfilter(c,e,tp,eg,resolution)
	return c:IsType(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_LIFEWEAVER)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and eg:IsExists(s.chkfilter,1,nil,tp,c:GetFuture(),c:GetAttribute(),false,resolution)
end
--E3
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not eg or #eg==0 then return false end
		local g=Duel.Group(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,eg,false)
		return #g>0
	end
	Duel.SetTargetCard(eg:Filter(s.condfilter,nil,nil,tp))
	local eid=e:GetFieldID()
	Duel.SetTargetParam(eid)
	for tc in aux.Next(eg) do
		if s.chkfilter(tc,tp,nil,nil,true) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(id)
			e1:SetLabel(eid,tc:GetPreviousFutureOnField(),tc:GetPreviousAttributeOnField())
			e1:SetValue(1)
			e1:SetReset(RESET_CHAIN)
			tc:RegisterEffect(e1,true)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS),Duel.GetTargetParam())
	if #g>0 then
		Duel.HintMessage(tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end