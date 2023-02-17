--Psychostizia Neutralizzatore Armageddon
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--bigbang
	aux.AddOrigBigbangType(c)
	c:EnableReviveLimit()
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD)
	ge2:SetCode(EFFECT_SPSUMMON_PROC)
	ge2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	ge2:SetRange(LOCATION_EXTRA)
	ge2:SetCondition(s.BigbangCondition)
	ge2:SetTarget(s.BigbangTarget)
	ge2:SetOperation(aux.BigbangOperation)
	ge2:SetValue(340)
	c:RegisterEffect(ge2)
	--material check
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.matcon)
	e0:SetOperation(s.matop)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	--protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.descon)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	--prevent act
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetCondition(s.atkcon)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
end
function s.proton(c)
	return c:IsRace(RACE_PSYCHO) and c:GetVibe()==1
end
function s.electron(c)
	return c:IsSetCard(0x2c2) and c:GetVibe()==-1
end
function s.mat1(c)
	return c:IsSetCard(0x2c2) and c:IsType(TYPE_BIGBANG)
end
function s.mat2(c)
	return c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_PANDEMONIUM)
end

function s.BigbangCondition(e,c,matg,mustg)
	if c==nil then return true end
	if (c:IsType(TYPE_PENDULUM) or c:IsType(TYPE_PANDEMONIUM)) and c:IsFaceup() then return false end
	local tp=c:GetControler()
	local list={{{s.proton,1,1},{s.electron,1,99}},{{s.mat1,1,1},{s.mat2,1,1}}}
	
	for i,plist in ipairs(list) do
		local e1
		if i==2 then
			e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_IGNORE_BIGBANG_SUMREQ)
			c:RegisterEffect(e1)
		end
		local mg,mg2
		if matg and aux.GetValueType(matg)=="Group" then
			mg=matg:Filter(Card.IsCanBeBigbangMaterial,nil,c)
			mg2=matg:Filter(Auxiliary.BigbangExtraFilter,nil,c,tp,table.unpack(plist))			
		else
			mg=Duel.GetMatchingGroup(Card.IsCanBeBigbangMaterial,tp,LOCATION_MZONE,0,nil,c)
			mg2=Duel.GetMatchingGroup(Auxiliary.BigbangExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(plist))
		end
		if #mg2>0 then mg:Merge(mg2) end
		local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_BIGBANG_MATERIAL)
		if mustg and aux.GetValueType(mustg)=="Group" then
			fg:Merge(mustg)
		end
		if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
		Duel.SetSelectedCard(fg)
		local res=mg:IsExists(Auxiliary.BigbangRecursiveFilter,1,nil,tp,Group.CreateGroup(),mg,c,0,table.unpack(plist))
		if i==2 then
			e1:Reset()
			e1=nil
		end
		if res then
			return true
		end
	end
	return false
end
function s.BigbangTarget(e,tp,eg,ep,ev,re,r,rp,chk,c)
	if bigbang_limit_mats_operation and bigbang_limit_mats_operation.SetLabelObject then
		Duel.RegisterEffect(bigbang_limit_mats_operation,tp)
	end
	if bigbang_force_mats_operation and bigbang_force_mats_operation.SetLabelObject then
		local forcedmat=bigbang_force_mats_operation:GetLabelObject()
		if forcedmat then
			if aux.GetValueType(forcedmat)=="Card" then
				forcedmat:RegisterEffect(bigbang_force_mats_operation)
			elseif aux.GetValueType(forcedmat)=="Group" then
				for tc in aux.Next(forcedmat) do
					tc:RegisterEffect(bigbang_force_mats_operation)
				end
			end
		end
	end
	
	local e1
	local list={{{s.proton,1,1},{s.electron,1,99}},{{s.mat1,1,1},{s.mat2,1,1}}}
	local ops=0
	local res1=aux.BigbangCondition(table.unpack(list[1]))(e,c)
	e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_IGNORE_BIGBANG_SUMREQ)
	c:RegisterEffect(e1)
	local res2=aux.BigbangCondition(table.unpack(list[2]))(e,c)
	e1:Reset()
	e1=nil
	if res1 and res2 then
		ops=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))+1
	elseif res1 then
		ops=1
	else
		ops=2
	end
	if ops==2 then
		e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_IGNORE_BIGBANG_SUMREQ)
		c:RegisterEffect(e1)
	end
	
	local funs=list[ops]
	local min,max=0,0
	for i=1,#funs do
		min=min+funs[i][2] max=max+funs[i][3]
	end
	if max>99 then max=99 end
	local mg=Duel.GetMatchingGroup(Card.IsCanBeBigbangMaterial,tp,LOCATION_MZONE,0,nil,c)
	local mg2=Duel.GetMatchingGroup(Auxiliary.BigbangExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(funs))
	if #mg2>0 then mg:Merge(mg2) end
	local bg=Group.CreateGroup()
	local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_BIGBANG_MATERIAL)}
	for _,te in ipairs(ce) do
		local tc=te:GetHandler()
		if tc then bg:AddCard(tc) end
	end
	if #bg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
		bg:Select(tp,#bg,#bg,nil)
	end
	local sg=Group.CreateGroup()
	sg:Merge(bg)
	local finish=false
	while not (#sg>=max) do
		finish=Auxiliary.BigbangCheckGoal(tp,sg,c,#sg,table.unpack(funs))
		local cg=mg:Filter(Auxiliary.BigbangRecursiveFilter,sg,tp,sg,mg,c,#sg,table.unpack(funs))
		if #cg==0 then break end
		local cancel=not finish
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tc=cg:SelectUnselect(sg,tp,finish,cancel,min,max)
		if not tc then break end
		if not bg:IsContains(tc) then
			if not sg:IsContains(tc) then
				sg:AddCard(tc)
				if (#sg>=max) then finish=true end
			else
				sg:RemoveCard(tc)
			end
		elseif #bg>0 and #sg<=#bg then
			if bigbang_limit_mats_operation and bigbang_limit_mats_operation.SetLabelObject then
				bigbang_limit_mats_operation:Reset()
				bigbang_limit_mats_operation=nil
			end
			if bigbang_force_mats_operation and bigbang_force_mats_operation.SetLabelObject then
				bigbang_force_mats_operation:Reset()
				bigbang_force_mats_operation=nil
			end
			return false
		end
	end
	if finish then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		if bigbang_limit_mats_operation and bigbang_limit_mats_operation.SetLabelObject then
			bigbang_limit_mats_operation:Reset()
			bigbang_limit_mats_operation=nil
		end
		if bigbang_force_mats_operation and bigbang_force_mats_operation.SetLabelObject then
			bigbang_force_mats_operation:Reset()
			bigbang_force_mats_operation=nil
		end
		if e1 then
			e1:Reset()
			e1=nil
		end
		return true
	else
		if bigbang_limit_mats_operation and bigbang_limit_mats_operation.SetLabelObject then
			bigbang_limit_mats_operation:Reset()
			bigbang_limit_mats_operation=nil
		end
		if bigbang_force_mats_operation and bigbang_force_mats_operation.SetLabelObject then
			bigbang_force_mats_operation:Reset()
			bigbang_force_mats_operation=nil
		end
		if e1 then
			e1:Reset()
			e1=nil
		end
		return false
	end
end

function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_BIGBANG) and e:GetLabel()==1
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	if mg:IsExists(Card.IsType,1,nil,TYPE_BIGBANG) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end

function s.descon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_BIGBANG)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if e:GetHandler():GetFlagEffect(id)>0 then
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
		g:Merge(sg)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.stcheck(c)
	return c:IsFaceup() or c:IsLocation(LOCATION_SZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local sg=Duel.GetMatchingGroup(s.stcheck,tp,0,LOCATION_ONFIELD,nil)
		if #sg>0 and e:GetHandler():GetFlagEffect(id)>0 then
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end

function s.rcfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP) and c:IsSetCard(0x2c2)
end
function s.atkcon(e)
	return Duel.IsBattlePhase() and Duel.IsExistingMatchingCard(s.rcfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,2,nil)
end
function s.atkop(e)
	Duel.Hint(HINT_CARD,e:GetHandlerPlayer(),id)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetReset(RESET_PHASE+PHASE_BATTLE)
	Duel.RegisterEffect(e2,e:GetHandlerPlayer())
end