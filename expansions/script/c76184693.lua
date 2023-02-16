--Ciclorporatura
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
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
	--
	c:Ignition(1,{CATEGORY_DESTROY,CATEGORY_LVCHANGE},EFFECT_FLAG_CARD_TARGET,false,{1,0},nil,nil,aux.Target(s.filter,LOCATION_MZONE,LOCATION_MZONE,1,1,true,s.check,s.info),s.operation,false,s.quickcon)
end
function s.spfilter(c)
	return c:IsMonster() and c:HasLevel() and c:IsLevelBelow(3) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,c)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(g:GetFirst():GetLevel())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
	e:GetHandler():RegisterEffect(e1)
	g:DeleteGroup()
end

function s.filter(c,e)
	return c:IsFaceup() and c:IsMonster() and c:HasLevel() and c:IsLevelBelow(e:GetHandler():GetLevel())
end
function s.check(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():HasLevel()
end
function s.info(g,e,tp,eg,ep,ev,re,r,rp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetCustomOperationInfo(0,CATEGORY_LVCHANGE,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local lv=tc:GetLevel()
		if Duel.Destroy(tc,REASON_EFFECT)>0 and c and c:IsRelateToEffect(e) and c:IsFaceup() and c:HasLevel() then
			c:ChangeLevel(c:GetLevel()+lv,true)
		end
	end
end
function s.quickcon(e)
	return e:GetHandler():IsLevelAbove(7)
end