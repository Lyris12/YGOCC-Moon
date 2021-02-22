--Radiant Quasaraphy
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--defup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetCondition(cid.defcon)
	e1:SetValue(cid.defval)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(cid.cost)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
	e2:SetLabel(0)
	c:RegisterEffect(e2)
	--lvchange
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetTarget(cid.lvtg)
	e3:SetOperation(cid.lvop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
end
function cid.counterfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:GetAttack()>0
end
--DEFUP
function cid.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and c:IsType(TYPE_MONSTER)
end
function cid.defcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function cid.defval(e,c)
	return Duel.GetMatchingGroupCount(cid.filter,c:GetControler(),LOCATION_MZONE,0,nil)*1000
end

--SPSUMMON
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.costfilter(c,e,tp,cc)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and c:IsType(TYPE_MONSTER) and c:GetOriginalLevel()>0
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,Group.FromCards(c,cc),c,e,tp,cc)
		and (not c:IsPublic() or (c:IsLocation(LOCATION_EXTRA) and c:IsFacedown()))
		and (c:IsReleasableByEffect() or cc:IsReleasableByEffect())
end
function cid.spfilter(c,tc,e,tp,cc)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and c:GetLevel()==tc:GetOriginalLevel()+cc:GetOriginalLevel()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():GetOriginalLevel()>0 and not e:GetHandler():IsPublic() and Duel.IsExistingMatchingCard(cid.costfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,e:GetHandler(),e,tp,e:GetHandler())
			and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
	end
	e:SetLabel(0)
	local g=Duel.SelectMatchingCard(tp,cid.costfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,e:GetHandler(),e,tp,e:GetHandler())
	g:AddCard(e:GetHandler())
	if #g>1 then
		Duel.ConfirmCards(1-tp,g)
		Duel.SetTargetCard(g)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.splimit)
	Duel.RegisterEffect(e1,tp)
end
function cid.splimit(e,c)
	return not cid.counterfilter(c)
end
function cid.rgfilter(c)
	return c:IsLocation(LOCATION_HAND+LOCATION_EXTRA) and c:IsType(TYPE_MONSTER) and c:IsReleasableByEffect()
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,tg:GetFirst(),e,tp,tg:GetNext())
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local rg=tg:FilterSelect(tp,cid.rgfilter,1,1,nil)
		if #rg>0 then
			Duel.HintSelection(rg)
			Duel.Release(rg,REASON_EFFECT)
		end
	end
end

--LVCHANGE
function cid.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetDefense()>=1000 and e:GetHandler():GetLevel()<12 end
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,e:GetHandler(),1,0,-1000)
end
function cid.lvop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsFaceup() or not e:GetHandler():IsRelateToEffect(e) then return end
	if e:GetHandler():GetDefense()<1000 or e:GetHandler():GetLevel()>=12 then return end
	local lmax=12-e:GetHandler():GetLevel()
	local m=math.floor(math.min(e:GetHandler():GetDefense(),lmax*1000)/1000)
	local t={}
	for i=1,m do
		t[i]=i*1000
	end
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	local def0=e:GetHandler():GetDefense()
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e0:SetCode(EFFECT_UPDATE_DEFENSE)
	e0:SetValue(-ac)
	e:GetHandler():RegisterEffect(e0)
	local def1=e:GetHandler():GetDefense()
	if def0~=def1 then
		ac=math.abs(def0-def1)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(math.floor(ac/1000))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1)
end
	