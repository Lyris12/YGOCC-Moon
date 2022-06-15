--Elohim, Zenit Ængelico
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	c:SetUniqueOnField(LOCATION_MZONE,0,id)
	--cannot remove
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CANNOT_BANISH)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(POS_FACEDOWN)
	c:RegisterEffect(e0)
	--special summon proc
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--spsummon cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_COST)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCost(s.spcost)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--search
	c:Ignition(2,CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE,nil,nil,1,nil,aux.LabelCost,s.tg,s.op)
	--
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return c:IsSetCard(0xae6)
end
function s.cf(c)
	return c:IsFacedown() or c:IsMonster() and not c:IsSetCard(0xae6)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	return not Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_REMOVED,0,1,nil) or Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		and not Duel.IsExistingMatchingCard(s.cf,tp,LOCATION_MZONE,0,1,nil) 
end
function s.spcost(e,c,tp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not s.counterfilter(c)
end

function s.costfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(0xae6) and c:IsAbleToRemoveAsCost(POS_FACEDOWN) and Duel.IsExistingMatchingCard(s.thf,tp,LOCATION_DECK,0,1,c,{c:GetCode()})
end
function s.thf(c,codes)
	return c:IsMonster() and c:IsRace(RACE_PSYCHO) and c:IsAbleToHand() and not c:IsCode(table.unpack(codes))
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	if #g>0 then
		local check=g:GetFirst():IsType(TYPE_TIMELEAP)
		e:SetLabel(table.unpack({g:GetFirst():GetCode()}))
		if Duel.Remove(g,POS_FACEDOWN,REASON_COST)>0 and g:GetFirst():IsBanished() and check then
			Duel.SetTargetParam(1)
		else
			Duel.SetTargetParam(0)
		end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local codes={e:GetLabel()}
	if #codes<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thf,tp,LOCATION_DECK,0,1,1,nil,codes)
	if #g>0 then
		local ct,hg=Duel.Search(g,tp)
		if ct>0 and hg>0 and Duel.GetTargetParam()==1 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil,tp,POS_FACEDOWN) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			local rg=Duel.Select(HINTMSG_REMOVE,false,tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil,tp,POS_FACEDOWN)
			if #rg>0 then
				Duel.HintSelection(rg)
				Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
			end
		end
	end
end