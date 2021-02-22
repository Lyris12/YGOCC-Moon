--Servanity of the Nobless
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
	--adjust for synchro
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(cid.sycost)
	e1:SetTarget(cid.sytg)
	e1:SetOperation(cid.syop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(cid.tdcost)
	e2:SetTarget(cid.tdtg)
	e2:SetOperation(cid.tdop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
end
function cid.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_ZOMBIE) and (c:IsHasNoArchetype() or c:IsType(TYPE_EXTRA))
end
--ADJUST FOR SYNCHRO
function cid.sycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function cid.tgfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ZOMBIE)
		and Duel.IsExistingMatchingCard(cid.lvfilter,tp,LOCATION_HAND,0,1,nil,c:GetLevel())
end
function cid.lvfilter(c,lv)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
		and c:GetLevel()>0 and (not c:IsLevel(lv) or lv~=c:GetLevel()*2)
end
function cid.sytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and cid.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(cid.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cid.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,g,#g,tp,0)
end
function cid.syop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,cid.lvfilter,tp,LOCATION_HAND,0,1,1,nil,tc:GetLevel())
		if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
			local sg=Duel.GetOperatedGroup():GetFirst()
			local op
			local b1,b2=tc:GetLevel()~=sg:GetLevel(),tc:GetLevel()~=(sg:GetLevel()*2)
			if b1 and b2 then
				op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
			elseif b1 then
				op=Duel.SelectOption(tp,aux.Stringid(id,2))
			elseif b2 then
				op=Duel.SelectOption(tp,aux.Stringid(id,3))+1
			end
			if not op then return end
			local val=(op==0) and sg:GetLevel() or sg:GetLevel()*2
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(val)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			--double mat
			if tc:IsType(TYPE_TUNER) then
				-- local e1=Effect.CreateEffect(e:GetHandler())
				-- e1:SetType(EFFECT_TYPE_SINGLE)
				-- e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
				-- e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
				-- e1:SetRange(LOCATION_MZONE)
				-- e1:SetTarget(cid.syntg)
				-- e1:SetValue(1)
				-- e1:SetOperation(cid.synop)
				-- e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				-- tc:RegisterEffect(e1)
				local fid=e:GetHandler():GetFieldID()
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
				e1:SetCode(EFFECT_SYNCHRO_MATERIAL_MULTIPLE)
				e1:SetRange(LOCATION_MZONE)
				e1:SetTarget(cid.synexcfilter)
				e1:SetValue(2)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				-- local e2=Effect.CreateEffect(e:GetHandler())
				-- e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				-- e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_IGNORE_IMMUNE)
				-- e2:SetCode(EVENT_ADJUST)
				-- e2:SetRange(LOCATION_MZONE)
				-- e2:SetLabel(fid)
				-- e2:SetValue(2)
				-- e2:SetCondition(cid.synexccon)
				-- e2:SetOperation(cid.synexcop)
				-- e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				-- tc:RegisterEffect(e2)
			end
		end
	end
end
-- function cid.synfilter(c,syncard,tuner,f)
	-- return c:IsFaceup() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
-- end
-- function cid.syncheck(c,g,mg,tp,lv,syncard,minc,maxc,double)
	-- g:AddCard(c)
	-- local ct=g:GetCount()
	-- local res1=(cid.syngoal(g,tp,lv,syncard,minc,ct,ct,nil) or (ct<maxc and mg:IsExists(cid.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc,nil)))
	-- local res2=(double~=nil and (cid.syngoal(g,tp,lv,syncard,minc,ct,ct+1,double) or ((ct+1)<maxc and mg:IsExists(cid.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc,double))))
	-- g:RemoveCard(c)
	-- return res1 or res2
-- end
-- function cid.syngoal(g,tp,lv,syncard,minc,ct0,ct,double)
	-- --local doublelv=(double~=nil) and double:GetSynchroLevel(syncard) or 0
	-- return ct>=minc and g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct0,ct0,syncard) and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
-- end
-- function cid.syntg(e,syncard,f,min,max)
	-- local minc=min+1
	-- local maxc=max+1
	-- local c=e:GetHandler()
	-- local tp=syncard:GetControler()
	-- local lv=syncard:GetLevel()
	-- if lv<=c:GetLevel() then return false end
	-- local g=Group.FromCards(c)
	-- local mg=Duel.GetMatchingGroup(cid.synfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c,syncard,c,f)
	-- local double=c--(syncard:IsRace(RACE_ZOMBIE)) and c or nil
	-- return mg:IsExists(cid.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc,double)
-- end
-- function cid.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	-- local minc=min+1
	-- local maxc=max+1
	-- local c=e:GetHandler()
	-- local lv=syncard:GetLevel()
	-- local g=Group.FromCards(c)
	-- local mg=Duel.GetMatchingGroup(cid.synfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c,syncard,c,f)
	-- local double=c--(syncard:IsRace(RACE_ZOMBIE)) and c or nil
	-- local doublemin=(double~=nil) and 1 or 0
	-- for i=1,maxc do
		-- local cg=mg:Filter(cid.syncheck,g,g,mg,tp,lv,syncard,minc,maxc,double)
		-- if cg:GetCount()==0 then break end
		-- local minct=1
		-- if cid.syngoal(g,tp,lv,syncard,minc,i,i-doublemin,double) then
			-- minct=0
		-- end
		-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		-- local sg=cg:Select(tp,minct,1,nil)
		-- if sg:GetCount()==0 then break end
		-- g:Merge(sg)
	-- end
	-- Duel.SetSynchroMaterial(g)
-- end
function cid.synexcfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_ZOMBIE)
end
--SEARCH
function cid.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
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
	return not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_ZOMBIE) and (c:IsHasNoArchetype() or c:IsType(TYPE_EXTRA)))
end
function cid.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function cid.thfilter(c,tp)
	return c:IsCode(id,id+1,id+2) and c:IsAbleToHand() and Duel.IsExistingMatchingCard(cid.thfilter2,tp,LOCATION_DECK,0,1,c,c:GetCode())
end
function cid.thfilter2(c,code)
	return c:IsCode(id,id+1,id+2) and c:IsAbleToHand() and not c:IsCode(code)
end
function cid.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SendtoDeck(g,nil,2,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g1=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		if #g1>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g2=Duel.SelectMatchingCard(tp,cid.thfilter2,tp,LOCATION_DECK,0,1,1,nil,g1:GetFirst():GetCode())
			if #g2>0 then
				g1:Merge(g2)
				Duel.SendtoHand(g1,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g1)
			end
		end
	end
end